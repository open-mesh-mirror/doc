.. SPDX-License-Identifier: GPL-2.0

Kernel hacking Debian image
===========================

The :doc:`OpenWrt image <OpenWrt_in_QEMU>` is an easy way to start multiple
virtual instances. But these instances usually don’t provide the
required infrastructure to test kernel modules extensively. And it also
depends on special toolchains to prepare the used tools/modules which
should tested.

It is often easier to use the same operating system in the virtual
environment and on the host. Only the kernel is modified here to provide
the necessary helpers for in-kernel development.

An interested reader might even extend this further to only provide a
modified kernel and use the currently running rootfs also in the virtual
environment. Such an approach is used in `hostap’s test
vm <https://w1.fi/cgit/hostap/tree/tests/hwsim/vm>`__ but it is out of
scope for this document.

Create an Image
---------------

The debian root filesystem is used here to a minimal system to boot and
run the test programs. It is a simple ext4 filesystem with only
userspace components from Debian. The configuration is changed to:

* automatically mount the shared folder
* automatically set up a static IPv4 address and hostname on bootup
* start a test-init.sh script from the shared folder on bootup
* disable root password
* prefer batctl binary from shared folder’s batctl subdirectory instead
  of virtual environment binary

The installation is also cleaned up at the end to reduce the required
storage space

.. code-block:: sh

  qemu-img create debian.img 8G
  sudo mkfs.ext4 -O '^has_journal' -F debian.img
  sudo mkdir debian
  sudo mount -o loop debian.img debian
  sudo debootstrap buster debian
  sudo systemd-nspawn -D debian apt update
  udo systemd-nspawn -D debian debian apt install --no-install-recommends build-essential vim openssh-server less \
   pkg-config libnl-3-dev libnl-genl-3-dev libcap-dev tcpdump rng-tools5 \
   trace-cmd flex bison libelf-dev libdw-dev binutils-dev libunwind-dev libssl-dev libslang2-dev liblzma-dev libperl-dev

  sudo mkdir debian/root/.ssh/
  ssh-add -L | sudo tee debian/root/.ssh/authorized_keys

  sudo mkdir debian/host
  sudo sh -c 'cat > debian/etc/fstab  << EOF
  host            /host   9p      trans=virtio,version=9p2000.L,posixacl,msize=524288 0 0
  EOF'

  sudo sh -c 'cat > debian/etc/rc.local << "EOF"
  #!/bin/sh -e

  MAC_PART="$(ip link show enp0s1 | awk "/ether/ {print \$2}"| sed -e "s/.*://" -e "s/[\\n\\ ].*//"|awk "{print (\"0x\"\$1)*1 }")"
  IP_PART="$(echo $MAC_PART|awk "{ print \$1+50 }")"
  NODE_NR="$(echo $MAC_PART|awk "{ printf(\"%02d\", \$1) }")"
  ip addr add 192.168.251.${IP_PART}/24 dev enp0s1
  ip link set up dev enp0s1
  hostname "node"$NODE_NR
  ip link set up dev lo
  [ ! -x /host/test-init.sh ] || /host/test-init.sh
  exit 0
  EOF'
  sudo chmod a+x debian/etc/rc.local

  sudo sed -i 's/^root:[^:]*:/root::/' debian/etc/shadow

  ## optionally: allow ssh logins without passwords
  # sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' debian/etc/ssh/sshd_config
  # sudo sed -i 's/^#PermitEmptyPasswords.*/PermitEmptyPasswords yes/' debian/etc/ssh/sshd_config
  # sudo sed -i 's/^UsePAM.*/UsePAM no/' debian/etc/ssh/sshd_config

  ## optionally: enable autologin for user root
  #sudo mkdir debian/etc/systemd/system/serial-getty@hvc0.service.d/
  #sudo sh -c 'cat > debian/etc/systemd/system/serial-getty@hvc0.service.d/autologin.conf  << EOF
  #[Service]
  #ExecStart=
  #ExecStart=-/sbin/agetty --autologin root -s %I 115200,38400,9600 vt102
  #EOF'

  sudo sh -c 'echo '\''PATH="/host/batctl/:$PATH"'\'' >> debian/etc/profile'
  sudo rm debian/var/cache/apt/archives/*.deb
  sudo rm debian/var/lib/apt/lists/*
  sudo e4defrag -v debian/
  sudo umount debian
  sudo fsck.ext4 -fD debian.img
  sudo zerofree -v debian.img
  sudo fallocate --dig-holes debian.img


  ## optionally: convert image to qcow2
  #sudo qemu-img convert -c -f raw -O qcow2 debian.img debian.qcow2
  #sudo mv debian.qcow2 debian.img

Kernel compile
--------------

Any recent kernel can be used for the setup. We will use linux-next here
to get the most recent development kernels. It is also assumed that the
sources are copied to the same directory as the debian.img and a x86_64
image will be used.

The kernel will be build to enhance the virtualization and debugging
experience. It is configured with:

* basic kernel features
* support for necessary drivers
* kernel hacking helpers
* kernel address + undefined sanitizers
* support for hwsim

.. code-block:: sh

  # make sure that libelf-dev is installed or module build will fail with something like "No rule to make target 'net/batman-adv/bat_algo.o'"

  git clone git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
  cd linux-next

  make allnoconfig
  cat >> .config << EOF

  # small configuration
  CONFIG_SMP=y
  CONFIG_EMBEDDED=n
  # CONFIG_EXPERT is not set
  CONFIG_MODULES=y
  CONFIG_MODULE_UNLOAD=y
  CONFIG_MODVERSIONS=y
  CONFIG_MODULE_SRCVERSION_ALL=y
  CONFIG_64BIT=y
  CONFIG_X86_VSYSCALL_EMULATION=n
  CONFIG_IA32_EMULATION=n
  CONFIG_VOP_BUS=y
  CONFIG_VOP=y
  CONFIG_HW_RANDOM_VIRTIO=y
  CONFIG_NET_9P_VIRTIO=y
  CONFIG_VIRTIO_MENU=y
  CONFIG_SCSI_VIRTIO=y
  CONFIG_VIRTIO_BALLOON=y
  CONFIG_VIRTIO_BLK=y
  CONFIG_VIRTIO_CONSOLE=y
  CONFIG_VIRTIO_INPUT=y
  CONFIG_VIRTIO_NET=y
  CONFIG_VIRTIO_PCI=y
  CONFIG_VIRTIO_PCI_LEGACY=y
  CONFIG_VIRTIO_BALLOON=y
  CONFIG_VIRTIO_BLK_SCSI=y
  CONFIG_VIRTIO_INPUT=y
  CONFIG_VIRTIO_MMIO=y
  CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y
  CONFIG_RPMSG_VIRTIO=y
  CONFIG_VSOCKETS=y
  CONFIG_VIRTIO_VSOCKETS=y
  CONFIG_DRM=y
  CONFIG_DRM_VIRTIO_GPU=y
  CONFIG_CAIF=y
  CONFIG_CAIF_VIRTIO=y
  CONFIG_CRYPTO_DEV_VIRTIO=y
  CONFIG_FUSE_FS=y
  CONFIG_VIRTIO_FS=y
  CONFIG_IOMMU_SUPPORT=y
  CONFIG_VIRTIO_IOMMU=y
  CONFIG_LIBNVDIMM=y
  CONFIG_VIRTIO_PMEM=y
  CONFIG_CRC16=y
  CONFIG_LIBCRC32C=y
  CONFIG_CRYPTO_SHA512=y
  CONFIG_NET=y
  CONFIG_INET=y
  CONFIG_DEBUG_FS=y
  CONFIG_IPV6=y
  CONFIG_BRIDGE=y
  CONFIG_VLAN_8021Q=y
  CONFIG_WIRELESS=n
  CONFIG_NET_9P=y
  CONFIG_NETWORK_FILESYSTEMS=y
  CONFIG_9P_FS=y
  CONFIG_9P_FS_POSIX_ACL=y
  CONFIG_9P_FS_SECURITY=y
  CONFIG_BLOCK=y
  CONFIG_BLK_DEV=y
  CONFIG_EXT4_FS=y
  CONFIG_EXT4_USE_FOR_EXT23=y
  CONFIG_TTY=y
  CONFIG_HW_RANDOM=y
  CONFIG_VHOST_RING=y
  CONFIG_GENERIC_ALLOCATOR=y
  CONFIG_SCSI_LOWLEVEL=y
  CONFIG_SCSI=y
  CONFIG_NETDEVICES=y
  CONFIG_NET_CORE=y
  CONFIG_DEVTMPFS=y
  CONFIG_HYPERVISOR_GUEST=y
  CONFIG_PVH=y
  CONFIG_PARAVIRT=y
  CONFIG_PARAVIRT_TIME_ACCOUNTING=y
  CONFIG_PARAVIRT_SPINLOCKS=y
  CONFIG_KVM_GUEST=y
  CONFIG_BINFMT_ELF=y
  CONFIG_BINFMT_SCRIPT=y
  CONFIG_BINFMT_MISC=y
  CONFIG_PCI=y
  CONFIG_SYSVIPC=y
  CONFIG_POSIX_MQUEUE=y
  CONFIG_CROSS_MEMORY_ATTACH=y
  CONFIG_UNIX=y
  CONFIG_TMPFS=y
  CONFIG_CGROUPS=y
  CONFIG_BLK_CGROUP=y
  CONFIG_CGROUP_CPUACCT=y
  CONFIG_CGROUP_DEVICE=y
  CONFIG_CGROUP_FREEZER=y
  CONFIG_CGROUP_HUGETLB=y
  CONFIG_CGROUP_NET_CLASSID=y
  CONFIG_CGROUP_NET_PRIO=y
  CONFIG_CGROUP_PERF=y
  CONFIG_CGROUP_SCHED=y
  CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
  CONFIG_INOTIFY_USER=y
  CONFIG_FHANDLE=y
  CONFIG_CFG80211=y
  CONFIG_DUMMY=y
  CONFIG_PACKET=y
  CONFIG_VETH=y
  CONFIG_IP_MULTICAST=y
  CONFIG_NET_IPGRE_DEMUX=y
  CONFIG_NET_IP_TUNNEL=y
  CONFIG_NET_IPGRE=y
  CONFIG_NET_IPGRE_BROADCAST=y
  # CONFIG_LEGACY_PTYS is not set
  CONFIG_NO_HZ_IDLE=y
  CONFIG_CPU_IDLE_GOV_HALTPOLL=y
  CONFIG_PVPANIC=y

  # makes boot a lot slower but required for shutdown
  CONFIG_ACPI=y


  #debug stuff
  CONFIG_CC_STACKPROTECTOR_STRONG=y
  CONFIG_LOCKUP_DETECTOR=y
  CONFIG_DETECT_HUNG_TASK=y
  CONFIG_SCHED_STACK_END_CHECK=y
  CONFIG_DEBUG_RT_MUTEXES=y
  CONFIG_DEBUG_SPINLOCK=y
  CONFIG_DEBUG_MUTEXES=y
  CONFIG_PROVE_LOCKING=y
  CONFIG_LOCK_STAT=y
  CONFIG_DEBUG_LOCKDEP=y
  CONFIG_DEBUG_ATOMIC_SLEEP=y
  CONFIG_DEBUG_LIST=y
  CONFIG_DEBUG_PI_LIST=y
  CONFIG_DEBUG_SG=y
  CONFIG_DEBUG_NOTIFIERS=y
  CONFIG_PROVE_RCU_REPEATEDLY=y
  CONFIG_SPARSE_RCU_POINTER=y
  CONFIG_DEBUG_STRICT_USER_COPY_CHECKS=y
  CONFIG_X86_VERBOSE_BOOTUP=y
  CONFIG_DEBUG_RODATA=y
  CONFIG_DEBUG_RODATA_TEST=n
  CONFIG_DEBUG_SET_MODULE_RONX=y
  CONFIG_PAGE_EXTENSION=y
  CONFIG_DEBUG_PAGEALLOC=y
  CONFIG_DEBUG_OBJECTS=y
  CONFIG_DEBUG_OBJECTS_FREE=y
  CONFIG_DEBUG_OBJECTS_TIMERS=y
  CONFIG_DEBUG_OBJECTS_WORK=y
  CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
  CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
  CONFIG_DEBUG_KMEMLEAK=y
  CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=8000
  CONFIG_DEBUG_STACK_USAGE=y
  CONFIG_DEBUG_STACKOVERFLOW=y
  CONFIG_DEBUG_INFO=y
  CONFIG_DEBUG_INFO_DWARF4=y
  CONFIG_GDB_SCRIPTS=y
  CONFIG_READABLE_ASM=y
  CONFIG_STACK_VALIDATION=y
  CONFIG_WQ_WATCHDOG=y
  CONFIG_DEBUG_KOBJECT_RELEASE=y
  CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
  CONFIG_OPTIMIZE_INLINING=y
  CONFIG_ENABLE_MUST_CHECK=y
  CONFIG_ENABLE_WARN_DEPRECATED=y
  CONFIG_DEBUG_SECTION_MISMATCH=y
  CONFIG_UNWINDER_ORC=y
  CONFIG_FTRACE=y
  CONFIG_FUNCTION_TRACER=y
  CONFIG_FUNCTION_GRAPH_TRACER=y
  CONFIG_FTRACE_SYSCALLS=y
  CONFIG_TRACER_SNAPSHOT=y
  CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
  CONFIG_STACK_TRACER=y
  CONFIG_UPROBE_EVENTS=y
  CONFIG_DYNAMIC_FTRACE=y
  CONFIG_FUNCTION_PROFILER=y
  CONFIG_HIST_TRIGGERS=y
  CONFIG_SYMBOLIC_ERRNAME=y
  CONFIG_DYNAMIC_DEBUG=y
  CONFIG_PRINTK_TIME=y
  CONFIG_PRINTK_CALLER=y
  CONFIG_DEBUG_MISC=y
  CONFIG_PROVE_RCU_LIST=y
  CONFIG_DEBUG_FORCE_FUNCTION_ALIGN_32B=y

  # for GCC 5+
  CONFIG_KASAN=y
  CONFIG_KASAN_INLINE=y
  CONFIG_UBSAN_SANITIZE_ALL=y
  CONFIG_UBSAN=y
  CONFIG_UBSAN_NULL=y
  EOF
  make olddefconfig

  cat >> .config << EOF
  # allow to use unsigned regdb with hwsim
  CONFIG_EXPERT=y
  CONFIG_CFG80211_CERTIFICATION_ONUS=y
  # CONFIG_CFG80211_REQUIRE_SIGNED_REGDB is not set
  EOF
  make olddefconfig

  make all -j$(nproc || echo 1)

Build the BIOS
--------------

The (sea)bios used by qemu is nice to boot all kind of legacy images but
reduces the performance for booting a paravirtualized Linux system.
Something like qboot works better for this purpose:

.. code-block:: sh

  git clone https://github.com/bonzini/qboot.git
  cd qboot
  meson build && ninja -C build
  cd ..

.. _open-mesh-kernel-hacking-debian-image-building-the-batman-adv-module:

Building the batman-adv module
------------------------------

The kernel module can be build outside the virtual environment and
shared over the 9p mount. The path to the kernel sources have to be
provided to the make process

.. code-block:: sh

  make KERNELPATH="$(pwd)/../linux-next"

The kernel module can also be compiled in a way which creates better
stack traces and increases the usability with (k)gdb:

.. code-block:: sh

  make EXTRA_CFLAGS="-fno-inline -Og -fno-optimize-sibling-calls" KERNELPATH="$(pwd)/../linux-next" V=1

Start of the environment
------------------------

virtual network initialization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The
:ref:`virtual-network.sh from the OpenWrt environment <open-mesh-openwrt-in-qemu-virtual-network-initialization>`
can be reused again.

VM instances bringup
~~~~~~~~~~~~~~~~~~~~

The 
:ref:`run.sh from the OpenWrt environment <open-mesh-openwrt-in-qemu-vm-instances-bringup>`
can mostly be reused. There are only minimal
adjustments required.

The BASE_IMG is of course no longer the same because a new image
“debian.img” was created for our new environment. The image also doesn’t
contain a bootloader or kernel anymore. The kernel must now be supplied
manually to qemu.

.. code-block:: sh

  BASE_IMG=debian.img
  BOOTARGS+=("-bios" "qboot/build/bios.bin")
  BOOTARGS+=("-kernel" "linux-next/arch/x86/boot/bzImage")
  BOOTARGS+=("-append" "root=/dev/vda rw console=hvc0 nokaslr tsc=reliable no_timer_check noreplace-smp rootfstype=ext4 rcupdate.rcu_expedited=1 reboot=t pci=lastbus=0 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 i8042.noaux=1")
  BOOTARGS+=("-device" "virtconsole,chardev=charconsole0,id=console0")

It is also recommended to use linux-next/vmlinux instead of bzImage with
qemu 4.0.0 (or later)

Automatic test initialization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The
:ref:`test-init.sh from the OpenWrt environment <open-mesh-openwrt-in-qemu-automatic-test-initialization>`
is always test specific. But its main
functionality is still the same as before. A simple example would be:

.. code-block:: sh

  cat > test-init.sh << "EOF"
  #! /bin/sh

  set -e

  ## get internet access
  dhclient enp0s2

  ## Simple batman-adv setup

  # ip link add dummy0 type dummy
  ip link set up dummy0

  rmmod batman-adv || true
  insmod /host/batman-adv/net/batman-adv/batman-adv.ko
  /host/batctl/batctl routing_algo BATMAN_IV
  /host/batctl/batctl if add dummy0
  /host/batctl/batctl it 5000
  /host/batctl/batctl if add enp0s1
  ip link set up dev enp0s1
  ip link set up dev bat0
  EOF

  chmod +x test-init.sh

Start
-----

The startup method 
:ref:`from the OpenWrt environment <open-mesh-openwrt-in-qemu-start>`
should be used here.
