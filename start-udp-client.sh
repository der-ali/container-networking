#!/bin/bash
. env.sh

# on the second host
#sudo ethtool -K eth1 tx off sg off tso off ufo off rx off
sudo ip netns exec $CON1 bash -c "for i in \$(seq 1 20);do echo packet num \$i from \$HOSTNAME && sleep 1;done | nc -u $TO_NODE_IP 1111"
#sudo ip netns exec $CON1 bash -c "echo $TO_NODE_IP"
