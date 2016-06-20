#!/bin/bash

DIR=$PWD
DST="fe80::6670:2ff:feae:72e4%eth1"
num=25


wait_for_link() {
	echo -n "Waiting for link..."

	while true; do
		ping6 "$DST" -q -c3 > /dev/null && break
		sleep 1
		echo -n "."
	done

	echo " Got link!"
}

usage() {
	echo "Eh, what? Unimplemented?"
}

WITHFDB=1
TGCMD="batctl tg | wc -l"
NMCONF=0
LOGDIR="$DIR/logs"

WIFIOFF=0

while getopts "hFTWnl:" opt; do
	case $opt in
		h)	usage; exit 1 ;;
		# Without fdb
		F)	WITHFDB=0 ;;
		# Without TG
		T)	TGCMD="cat /sys/kernel/debug/batman_adv/bat0/transtable_global_count" ;;
		# Without Wifi
		W)	WIFIOFF=1 ;;
		n)	NMCONF=1 ;;
		l)	LOGDIR=$OPTARG ;;
	esac
done

[ ! -d "$LOGDIR" ] && mkdir -p "$LOGDIR"
[ ! -d "$LOGDIR" ] && {
	echo "Error: Could not create logdir \"$LOGDIR\""
	exit 1
}

[ $NMCONF -eq 0 ] || grep -q "### Test configuration ###" /etc/network/interfaces || {
	echo "\n### Test configuration ###" >> /etc/network/interfaces
	cat "$DIR/nm-test-interfaces" >> /etc/network/interfaces
	systemctl reload NetworkManager
}

chvt 1
sysctl kernel.panic=10

rmmod bridge
sleep 5
rmmod batman_adv

modprobe bridge

brctl addbr br0
brctl addif br0 eth2

echo 0 > /proc/sys/net/ipv6/conf/br0/accept_ra
echo 0 > /proc/sys/net/ipv6/conf/eth1/accept_ra
echo 0 > /proc/sys/net/ipv6/conf/eth2/accept_ra

ip link set up dev br0
ip link set up dev eth1
ip link set up dev eth2

wait_for_link

# Clean start
echo "Rebooting device, clean start"
ssh -i $DIR/testnode42 root@$DST \
	"uci set wireless.client_radio0.disabled=$WIFIOFF; \
	 uci set wireless.client_radio0.hidden=1; \
	 uci set wireless.ibss_radio0.disabled=$WIFIOFF; \
	 uci set wireless.ibss_radio0.hidden=1; \
	 sed -i 's/^\([^#].*autoupdater\)/#\1/' /usr/lib/micron.d/autoupdater; \
	 uci commit; sync; reboot" || {
	echo "Error: Could not reboot device"
	exit 1
}


modprobe crc16
modprobe crc32
modprobe libcrc32c

insmod $DIR/batman-adv/net/batman-adv/batman-adv.ko || {
	echo "Error: Could not load batman-adv.ko"
	exit 2
}

echo "Modules loaded, Wiring things now"
for i in `seq 1 $num`; do
	ip link add dev veth$i-2 type veth peer name veth$i-1
	brctl addif br0 veth$i-1
	echo bat$i > /sys/class/net/veth$i-2/batman_adv/mesh_iface

	ip link set up dev veth$i-1
	ip link set up dev veth$i-2
	ip link set up dev bat$i
done


# Wait for reboot to settle
echo Waiting for device reboot
sleep 5
wait_for_link

[ $WITHFDB -eq 0 ] && {
	ssh -i $DIR/testnode42 root@$DST \
		"echo 0 > /sys/class/net/br-client/brif/bat0/learning; \
		echo 1 > /sys/class/net/br-client/brif/bat0/flush; \
		echo 0 > /sys/class/net/br-client/brif/eth1/unicast_flood" || {

		echo "Error: Could not disable FDB on bat0"
		exit 3
	}
}

# Wait a little longer for protocol establishment etc.
sleep 10

echo "Configuration complete"

MYDATE=`date "+%s"`
ssh -i $DIR/testnode42 root@$DST \
	"date -s @$MYDATE; \
	while true; do \
		echo =============================; \
		echo \"Date: \$(date) // \$(date +%s)\"; \
		echo \"TG-size: \$($TGCMD)\"; \
		echo \"FDB-size: \$(bridge fdb show brport bat0 | wc -l)\"; \
		echo \"Load: \$(cat /proc/loadavg)\"; \
		cat /proc/meminfo; \
		echo -----------------------------; \
		sleep 1; \
	done" > $LOGDIR/out-$MYDATE.log &

MYPID="$!"
trap "echo \"Got trap! Killing $MYPID\"; [ -n \"$MYPID\" ] && kill $MYPID; killall mz" SIGINT SIGTERM EXIT
sleep 5

echo "Logging started, firing mz"

for i in `seq 1 $num`; do
	mz bat$i -c 1500 -p 64 -d 10msec -a rand -A -b bcast -t udp || {
		echo "Error: Could not start mausezahn on interface bat$i"
		exit 1
	}
done &

count=0
size=0
sizenew=0
while true; do
	sleep 10
	size=$sizenew
	sizenew=`ls -l $LOGDIR/out-$MYDATE.log | awk '{ print $5 }'`
	[ $sizenew -ne $size ] && continue

	count=$(($count + 1))
	[ $count -eq 3 ] && break
done
	
kill "$MYPID"
killall mz
rmmod bridge
echo "Stopped at `date` (`date +%s`)"
