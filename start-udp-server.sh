#!/bin/bash
# on host 1
. env.sh
if [[ $# -lt 1 ]] ; then 
    echo 'Please NAT type (iptables or ebpf)' 
    exit 0 
fi 

NAT=$1
CON_MAC=$(sudo ip netns exec $CON1 ip -o link | awk '$2 ~ "veth11" {print $(NF-4)}')

function cleanup {
if [ $NAT == "iptables" ];then
  echo "Clean up nat table"
  sudo iptables -t nat -F
elif [ $NAT == "ebpf" ];then
  echo "kill ebpf-xdp process"
  sudo pkill -9 "ebpf-xdp"
fi  
}

if [ $NAT == "iptables" ];then
  echo "Setting up NAT rule with iptables for the udp server on port 1111"
  sudo iptables -t nat -A PREROUTING -i $INTERFACE -p udp -d $NODE_IP --dport 1111 -j DNAT --to-destination $IP1:1111
elif [ $NAT == "ebpf" ];then
  echo "Setting up NAT rule with ebpf xdp for the udp server on port 1111"
  cmd="sudo ./ebpf-xdp -bip $IP1 -cip $IP1 -cmac $CON_MAC -dif veth10 -sif $INTERFACE -sip $NODE_IP"
  $cmd &
fi

echo "Starting UDP server on port 1111"
sudo ip netns exec $CON1 nc -klu $IP1 1111

trap cleanup EXIT
