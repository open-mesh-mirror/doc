#! /bin/sh

SHARED_PATH=/home/sven/tmp/qemu-batman/

for i in `seq 1 5`; do
	qemu-img create -b debian.img -f qed root.cow$i
	normalized_id=`echo "$i"|awk '{ printf "%02d\n",$1 }'`
	screen qemu-system-x86_64 -enable-kvm -kernel bzImage -append "root=/dev/vda rw console=ttyS0" \
		-smp 2 -m 512 -drive file=root.cow$i,if=virtio \
		-netdev type=tap,id=net0,ifname=tap$i,script=no -device virtio-net-pci,mac=02:ba:de:af:fe:`echo $i|awk '{ printf "%02X", $1 }'`,netdev=net0 \
		-virtfs local,path="${SHARED_PATH}",security_model=none,mount_tag=host \
		-nographic
	sleep 1
done
