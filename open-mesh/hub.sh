#! /bin/sh
USER="$(whoami)"
BRIDGE=br0
ETH=eth0

sudo ip link add "${BRIDGE}" type bridge
for i in `seq 1 2`; do
	sudo ip tuntap add dev tap$i mode tap user "$USER"
	sudo ip link set tap$i up
	sudo ip link set tap$i master "${BRIDGE}"
done

sudo ip link set "${BRIDGE}" up

sudo ip addr flush dev "${ETH}"
sudo ip link set "${ETH}" master "${BRIDGE}"
sudo dhclient "${BRIDGE}"
