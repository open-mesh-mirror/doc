#! /bin/sh
USER="$(whoami)"
BRIDGE=br0
ETH=enp8s0
VXLAN=vx_mesh_lan
# calculated on gluon node via: lua -lgluon.util -e 'print(tonumber(gluon.util.domain_seed_bytes("gluon-mesh-vxlan", 3), 16))'
VXLAN_ID=12094920


xor2() {
        echo -n "${1:0:1}"
        echo -n "${1:1:1}" | tr '0123456789abcdef' '23016745ab89efcd'
}

interface_linklocal() {
        local macaddr="$(cat /sys/class/net/"${ETH}"/address)"
        local oldIFS="$IFS"; IFS=':'; set -- $macaddr; IFS="$oldIFS"

        echo "fe80::$(xor2 "$1")$2:$3ff:fe$4:$5$6"
}

sudo ip link add "${BRIDGE}" type bridge
for i in `seq 1 5`; do
	sudo ip tuntap add dev tap$i mode tap user "$USER"
	sudo ip link set tap$i up
	sudo ip link set tap$i master "${BRIDGE}"
done

sudo ip link set "${BRIDGE}" up

sudo ip addr add "$(interface_linklocal)"/64 dev "$ETH"
sudo ip link del "${VXLAN}"
sudo ip -6 link add "${VXLAN}" type vxlan \
   id "${VXLAN_ID}" \
   dstport 4789 \
   local "$(interface_linklocal)" \
   group ff02::15c \
   dev "${ETH}" \
   udp6zerocsumtx udp6zerocsumrx \
   ttl 1

sudo ip link set "${VXLAN}" up master "${BRIDGE}"
sudo ip addr replace 192.168.2.1/24 dev "${BRIDGE}"
