#!/bin/bash -e 

. env.sh
if [[ $# -lt 2 ]] ; then
    echo 'routing type is missing!'
    echo 'please provide routing type (host or bgp) and NAT type (iptables or ebpf)'
    exit 0
fi

ROUTING_PROTO=$1
NAT=$2


echo "Creating the namespaces"
sudo ip netns add $CON1
sudo ip netns add $CON2

echo "Creating the veth pairs"
sudo ip link add veth10 type veth peer name veth11
sudo ip link add veth20 type veth peer name veth21

echo "Adding the veth pairs to the namespaces"
sudo ip link set veth11 netns $CON1
sudo ip link set veth21 netns $CON2

echo "Configuring the interfaces in the network namespaces with IP address"
sudo ip netns exec $CON1 ip addr add $IP1/24 dev veth11 
sudo ip netns exec $CON2 ip addr add $IP2/24 dev veth21 

echo "Enabling the interfaces inside the network namespaces"
sudo ip netns exec $CON1 ip link set dev veth11 up
sudo ip netns exec $CON2 ip link set dev veth21 up

echo "Creating the bridge"
sudo ip link add name br0 type bridge

echo "Adding the network namespaces interfaces to the bridge"
sudo ip link set dev veth10 master br0
sudo ip link set dev veth20 master br0

echo "Assigning the IP address to the bridge"
sudo ip addr add $BRIDGE_IP/24 dev br0

echo "Enabling the bridge"
sudo ip link set dev br0 up

echo "Enabling the interfaces connected to the bridge"
sudo ip link set dev veth10 up
sudo ip link set dev veth20 up

echo "Setting the loopback interfaces in the network namespaces"
sudo ip netns exec $CON1 ip link set lo up
sudo ip netns exec $CON2 ip link set lo up

echo "Setting the default route in the network namespaces"
sudo ip netns exec $CON1 ip route add default via $BRIDGE_IP dev veth11
sudo ip netns exec $CON2 ip route add default via $BRIDGE_IP dev veth21

# ------------------- Step 3 Specific Setup --------------------- #

if [ $ROUTING_PROTO == "static" ];then
	echo "Setting the route on the node to reach the network namespaces on the other node"
	sudo ip route add $TO_BRIDGE_SUBNET via $TO_NODE_IP dev eth1
elif [ $ROUTING_PROTO == "bgp" ];then
	echo "Setting the bgp route with bird"
	envsubst < bird.conf | sudo tee /etc/bird/bird.conf
	sudo systemctl restart bird
fi
	

echo "Enables IP forwarding on the node"
sudo sysctl -w net.ipv4.ip_forward=1

echo "Setup iptable rules"
#sudo iptables --append FORWARD --in-interface eth1 --out-interface veth11 --jump ACCEPT
#sudo iptables --append FORWARD --in-interface eth1 --out-interface veth21 --jump ACCEPT
#sudo iptables --append FORWARD --in-interface veth11 --out-interface eth1 --jump ACCEPT
#sudo iptables --append FORWARD --in-interface veth21 --out-interface eth1 --jump ACCEPT
sudo iptables --append POSTROUTING --table nat --out-interface eth1 --jump MASQUERADE


if [ $NAT == "iptables" ];then
	echo "Setting up NAT rule with iptables for the udp server on port 1111"
	sudo iptables -t nat -A PREROUTING -i $INTERFACE -p udp -d $NODE_IP --dport 1111 -j DNAT --to-destination $IP1:1111
elif [ $NAT == "ebpf" ];then
	echo "Setting up NAT rule with ebpf xdp for the udp server on port 1111"
	sudo ./ebpf-xdp -bip $BRIDGE_IP -cip $IP1 -cmac c2:39:ed:47:ea:c4 -dif br0 -sif eth1 -sip $NODE_IP
fi
