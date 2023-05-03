#!/bin/bash

. env.sh

echo "Deleting the namespaces"
ip netns list | grep $CON1
if [ $? -eq 0 ]; then
    sudo ip netns delete $CON1
fi
ip netns list | grep $CON2
if [ $? -eq 0 ]; then
    sudo ip netns delete $CON2
fi

echo "Deleting the bridge"
sudo ip link delete br0

echo "Deleting the route on the node $TO_NODE_IP to reach the network namespaces on the other node $TO_BRIDGE_SUBNET"
sudo ip route del $TO_BRIDGE_SUBNET via $TO_NODE_IP dev eth1

echo "Deleting bird routes"
sudo systemctl stop bird

echo "Flush iptable rules"
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X 

echo "Disable IP forwarding"
sudo sysctl -w net.ipv4.ip_forward=0
