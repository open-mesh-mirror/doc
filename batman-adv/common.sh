#!/bin/sh
QEMU=$(which kvm)
VDESWITCH=../dev/vde2-2.3.1/src/vde_switch/vde_switch
IMAGE=../openwrt.trunk/bin/x86/openwrt-x86-kvm_guest-combined-ext4.img.gz

# you can set this if you are running as root and don't need sudo:
# SUDO=
SUDO=sudo

${SUDO} killall -q ${QEMU} wirefilter vde_switch qemu-system-x86_64
sleep 1
${SUDO} killall -q -9 ${QEMU} wirefilter vde_switch qemu-system-x86_64

