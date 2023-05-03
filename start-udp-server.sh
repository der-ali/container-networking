#!/bin/bash
# on host 1
. env.sh
#sudo ip netns exec $CON1 ethtool -K veth11 tx off sg off tso off ufo off rx off

sudo ip netns exec $CON1 timeout 13s nc -klu $IP1 1111

