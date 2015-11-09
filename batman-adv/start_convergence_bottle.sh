#!/bin/sh

. ./common.sh

NUM=10

for i in $(seq 1 ${NUM}); 
do
	${VDESWITCH} \
		-d --hub --sock num0_${i}.ctl -f colourful.rc
	${VDESWITCH} \
		-d --hub --sock num1_${i}.ctl -f colourful.rc

done

for i in $(seq 1 ${NUM}); 
do
	if $(echo $IMAGE | grep -q "\.gz$"); then
		gunzip -c ${IMAGE} > num${i}.image
	else
		cp ${IMAGE} num${i}.image
	fi
	screen ${SUDO} ${QEMU} \
		-no-acpi -m 48M \
		-net vde,sock=num0_${i}.ctl,port=1,vlan=0 -net nic,macaddr=fe:f0:00:00:$(printf %02x $i):01,model=virtio,vlan=0 \
		-net vde,sock=num1_${i}.ctl,port=1,vlan=1 -net nic,macaddr=fe:f1:00:00:$(printf %02x $i):01,model=virtio,vlan=1 \
		-net nic,model=virtio,vlan=2 -net tap,ifname=tapwrt${i},vlan=2 \
        -nographic -drive file=num${i}.image,if=virtio
	sleep 1
	${SUDO} /sbin/ifconfig tapwrt${i} inet 192.168.${i}.1 up
done

# The bottle:
# A = 9
# B = 10
# Nx = x
wirefilter --daemon -v num0_9.ctl:num0_1.ctl
wirefilter --daemon -v num0_1.ctl:num0_2.ctl
wirefilter --daemon -v num0_2.ctl:num0_3.ctl
wirefilter --daemon -v num0_3.ctl:num0_4.ctl  --pidfile killmeTOP.pid
wirefilter --daemon -v num0_4.ctl:num0_5.ctl
wirefilter --daemon -v num0_5.ctl:num0_10.ctl

wirefilter --daemon -v num0_2.ctl:num0_6.ctl
wirefilter --daemon -v num0_6.ctl:num0_7.ctl  --pidfile killmeBOTTOM.pid
wirefilter --daemon -v num0_7.ctl:num0_8.ctl
wirefilter --daemon -v num0_8.ctl:num0_10.ctl

