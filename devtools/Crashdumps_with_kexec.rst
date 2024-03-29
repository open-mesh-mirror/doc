.. SPDX-License-Identifier: GPL-2.0

Crashdumps with kexec
=====================

[[Crashlog_with_pstore|Stack traces]] are a nice way to have a first
glance at a kernel problem. But sometimes the stack traces provide not
enough information and an offline (post-mortem) analysis would be
required. Normal coredumps can be used for userspace programs but this
wouldn’t provide any insights in the state of the kernel.

The kernel provides for this task the crash_dump feature which is based
on kexec. The latter is used to start a kernel on the running system -
replacing the old while bypassing system firmware and bootloaders. This
can either be triggered manually by system call or on a kernel panic.
Such a crash/panic handling requires that the system memory has a
portion of the system RAM’s physical address space reserved for the
crash kernel.

::

  +---------------+--------------+
  |               | Kernel code  |
  | Normal system | Kernel data  |
  | (running)     | Kernel bss   |
  |               | .....        |
  +---------------+--------------+
  |               | Kernel code  |
  | Crashkernel   | Kernel data  |
  | (loaded)      | Kernel bss   |
  |               | .....        |
  +---------------+--------------+

The kexec call to switch to the crashkernel is automatically triggered
when the panic handler is invoked. The crashkernel will try to boot a
new system which is then exposing the memory range of the “normal
system” as /proc/vmcore (in ELF format)

::

  +---------------+--------------+
  |               | Kernel code  |
  | Normal system | Kernel data  |
  | (/proc/vmcore)| Kernel bss   |
  |               | .....        |
  +---------------+--------------+
  |               | Kernel code  |
  | Crashkernel   | Kernel data  |
  | (running)     | Kernel bss   |
  |               | .....        |
  +---------------+--------------+

The ``/proc/vmcore`` file can be extracted from the crashkernel system and
analyzed offline together with the debug information from the vmlinux
binary.

System setup
------------

The setup of a system usually requires minor changes to the system

#. Enable ``CONFIG_KEXEC`` on your normal kernel
#. Enable debug options in your kernel (``CONFIG_DEBUG_INFO``,
   ``CONFIG_GDB_SCRIPTS``, ...)
#. install kexec-tools
#. Boot your kernel with the cmdline parameter ``crashkernel=<SIZE>@<ADDRESS>``
#. prepare a crashkernel (with ``CONFIG_CRASH_DUMP`` enabled) which has the
   correct address configured (either using ``CONFIG_RELOCATABLE=y`` or
   ``CONFIG_PHYSICAL_START`` set to ``<ADDRESS>``)
#. load panic kernel with appropriate cmdline (and/or DTB)
#. crash the system

But the details are architecture and system specific

x86-64
~~~~~~

The system setup for x86(–64) is rather straight forward. It is possible
to use a correct compiled kernel for both normal kernel and for the
crashkernel. There are even kdump packages under distributions like
OpenWrt and Debian which can automate the setup (after the kernel
commandline is configured correctly) and will only use the crashkernel
to save the /proc/vmcore to the filesystem before rebooting the system
again to return to the normal environment.

Let us check the setup on OpenWrt without using the kdump packages.
First step is to enable the KEXEC specific options in OpenWrt’s .config.
The boot cmdline can also directly set up during the image build (or
later changed under OpenWrt):

.. code-block:: diff

  diff --git a/.config b/.config
  index 5bcaeadfa2..a497950073 100644
  --- a/.config
  +++ b/.config
  @@ -3116,7 +3118,15 @@ CONFIG_PACKAGE_mkf2fs=y
   # CONFIG_PACKAGE_iwinfo is not set
   CONFIG_PACKAGE_jshn=y
   # CONFIG_PACKAGE_kdump is not set
  -# CONFIG_PACKAGE_kexec is not set
  +CONFIG_PACKAGE_kexec=y
  +
  +#
  +# Configuration
  +#
  +CONFIG_KEXEC_ZLIB=y
  +CONFIG_KEXEC_LZMA=y
  +# end of Configuration
  +
   # CONFIG_PACKAGE_kexec-tools is not set
   CONFIG_PACKAGE_libjson-script=y
   # CONFIG_PACKAGE_logger is not set
  diff --git a/target/linux/x86/image/Makefile b/target/linux/x86/image/Makefile
  index f61e4ff802..db3f5b2936 100644
  --- a/target/linux/x86/image/Makefile
  +++ b/target/linux/x86/image/Makefile
  @@ -9,7 +9,7 @@ GRUB2_VARIANT =
   GRUB_TERMINALS =
   GRUB_SERIAL_CONFIG =
   GRUB_TERMINAL_CONFIG =
  -GRUB_CONSOLE_CMDLINE =
  +GRUB_CONSOLE_CMDLINE = nokaslr crashkernel=128M

   ifneq ($(CONFIG_GRUB_CONSOLE),)
     GRUB_CONSOLE_CMDLINE += console=tty0
  </code>

When the system is booted, the reserved memory for the crash kernel
should be visible:

.. code-block:: shell

  root@OpenWrt:/# cat /proc/iomem |grep -e 'System RAM' -e 'Crash kernel'
  00001000-0009fbff : System RAM
  00100000-1ffdcfff : System RAM
    17000000-1effffff : Crash kernel

The system kernel must now be loaded in the “Crash kernel” region so the
panic handler can boot it on demand.

.. code-block:: shell

  root@OpenWrt:/# cat /proc/iomem |grep -e 'System RAM' -e 'Crash kernel'
  00001000-0009fbff : System RAM
  00100000-1ffdcfff : System RAM
    17000000-1effffff : Crash kernel
  </code>

.. code-block:: shell

  root@OpenWrt:/# kexec -p /boot/vmlinuz --reuse-cmdline --append '1 irqpoll nr_cpus=1 reset_devices'

To test the setup, a crash can be simulated using various mechanisms.
For example using sysrq:

.. code-block:: shell

  root@OpenWrt:/# echo c > /proc/sysrq-trigger

After the boot (without going through BIOS + grub), a file ``/proc/vmcore``
should be available which can be saved for further analysis.

ath79
~~~~~

The setup under ath79 is significantly more complicated. It already
starts with the problem that the normal kernel and the crashkernel are
completely different ones. This is the result of the missing relocation
support and the inability of kexec to load an uImage with appended DTB.

Another problem is the ``CONFIG_HARDENED_USERCOPY=y`` which prevents kexec
under MIPS at the moment. So just disable it in in the kernel
configuration. Also make sure that the devicetree for the device already
reserves some space for the crashkernel. In this example, it is a 128MB
device and 32 MB are reserved at the 16MB boundary

.. code-block:: diff

  diff --git a/target/linux/generic/config-5.4 b/target/linux/generic/config-5.4
  index e922d23d2c..0d24b4c041 100644
  --- a/target/linux/generic/config-5.4
  +++ b/target/linux/generic/config-5.4
  @@ -1881,7 +1881,7 @@ CONFIG_GPIO_SYSFS=y
   # CONFIG_HAMACHI is not set
   # CONFIG_HAMRADIO is not set
   # CONFIG_HAPPYMEAL is not set
  -CONFIG_HARDENED_USERCOPY=y
  +# CONFIG_HARDENED_USERCOPY is not set
   # CONFIG_HARDENED_USERCOPY_FALLBACK is not set
   # CONFIG_HARDENED_USERCOPY_PAGESPAN is not set
   CONFIG_HARDEN_EL2_VECTORS=y
  --- a/target/linux/ath79/dts/xxx_xxx.dts
  +++ b/target/linux/ath79/dts/xxx_xxx.dts
  @@ -12,5 +12,5 @@

      chosen {
  -       bootargs = "console=ttyS0,115200n8";
  +       bootargs = "console=ttyS0,115200n8 crashkernel=32M@0x01000000";
      };

      aliases {

This should be visible when booting this device:

.. code-block:: shell

  root@OpenWrt:/# cat /proc/iomem |grep -e 'System RAM' -e 'Crash kernel'
  00000000-07ffffff : System RAM
    01000000-02ffffff : Crash kernel

The device should of course also have the kexec support enabled in
OpenWrt’s .config

.. code-block:: diff

  diff --git a/.config b/.config
  index 54067570a2..8a88b5f140 100644
  --- a/.config
  +++ b/.config
  @@ -829,7 +829,7 @@ CONFIG_KERNEL_ELF_CORE=y
   CONFIG_KERNEL_PRINTK_TIME=y
   # CONFIG_KERNEL_SLABINFO is not set
   # CONFIG_KERNEL_PROC_PAGE_MONITOR is not set
  -# CONFIG_KERNEL_KEXEC is not set
  +CONFIG_KERNEL_KEXEC=y
   # CONFIG_USE_RFKILL is not set
   # CONFIG_USE_SPARSE is not set
   # CONFIG_KERNEL_DEVTMPFS is not set
  @@ -3704,6 +3712,16 @@ CONFIG_PACKAGE_uboot-envtools=y
   # CONFIG_PACKAGE_iwcap is not set
   CONFIG_PACKAGE_iwinfo=y
   CONFIG_PACKAGE_jshn=y
  +CONFIG_PACKAGE_kexec=y
  +
  +#
  +# Configuration
  +#
  +CONFIG_KEXEC_ZLIB=y
  +CONFIG_KEXEC_LZMA=y
  +# end of Configuration
  +
  +# CONFIG_PACKAGE_kexec-tools is not set
   CONFIG_PACKAGE_libjson-script=y
   # CONFIG_PACKAGE_libucode is not set
   # CONFIG_PACKAGE_logger is not set
  </code>

The next major part is to prepare a kernel which can be booted by kexec,
supports crashdump and is running from the correct physical address. The
former requires that the dtb is embedded as part of the elf binary -
which is not how OpenWrt is currently building the ath79 kernels.
Luckily, it only requires a config change
(``CONFIG_MIPS_RAW_APPENDED_DTB=y`` to ``CONFIG_MIPS_ELF_APPENDED_DTB=y``) and
some binutils commands (objcopy, strip, ...). The setup of crashdump is
also just a couple of configuration settings. The most important setting
is ``CONFIG_PHYSICAL_START`` which must match the address in crashkernel +
0x80000000 (the address where physical pages are mapped to in the
virtual address space for this architecture). And the bootargs must be
dropped from the devicetree to ensure that kexec can overwrite it:

.. code-block:: diff

  diff --git a/target/linux/ath79/config-5.4 b/target/linux/ath79/config-5.4
  index e37b728554..24892b7435 100644
  --- a/target/linux/ath79/config-5.4
  +++ b/target/linux/ath79/config-5.4
  @@ -160,10 +160,10 @@ CONFIG_MIPS_CLOCK_VSYSCALL=y
   # CONFIG_MIPS_CMDLINE_DTB_EXTEND is not set
   # CONFIG_MIPS_CMDLINE_FROM_BOOTLOADER is not set
   CONFIG_MIPS_CMDLINE_FROM_DTB=y
  -# CONFIG_MIPS_ELF_APPENDED_DTB is not set
  +CONFIG_MIPS_ELF_APPENDED_DTB=y
   CONFIG_MIPS_L1_CACHE_SHIFT=5
   # CONFIG_MIPS_NO_APPENDED_DTB is not set
  -CONFIG_MIPS_RAW_APPENDED_DTB=y
  +# CONFIG_MIPS_RAW_APPENDED_DTB is not set
   CONFIG_MIPS_SPRAM=y
   CONFIG_MODULES_USE_ELF_REL=y
   CONFIG_MTD_CFI_ADV_OPTIONS=y
  @@ -249,3 +249,7 @@ CONFIG_TICK_CPU_ACCOUNTING=y
   CONFIG_TINY_SRCU=y
   CONFIG_USB_SUPPORT=y
   CONFIG_USE_OF=y
  +
  +CONFIG_CRASH_DUMP=y
  +CONFIG_PROC_VMCORE=y
  +CONFIG_PHYSICAL_START=0x81000000
  --- a/target/linux/ath79/dts/xxx_xxx.dts
  +++ b/target/linux/ath79/dts/xxx_xxx.dts
  @@ -12,5 +12,5 @@

      chosen {
  -       bootargs = "console=ttyS0,115200n8 crashkernel=32M@0x01000000";
  +       /delete-property/ bootargs;
      };

      aliases {


As mentioned earlier, this kernel is not yet ready to be used because
the device tree must be embedded:

.. code-block:: shell

  $ LXBASE=./build_dir/target-mips_24kc_musl/linux-ath79_generic
  $ cp "$LXBASE"/vmlinux.elf vmlinux.elf
  $ mips-linux-gnu-strip vmlinux.elf
  $ mips-linux-gnu-objcopy --update-section .appended_dtb="$LXBASE"/image-xxx_xxx.dtb vmlinux.elf

The system kernel must now be loaded in the “Crash kernel” region so the
panic handler can boot it on demand.

.. code-block:: shell

  root@OpenWrt:/# kexec -p /tmp/vmlinux.elf --command-line "" --append "$(cat /proc/cmdline) 1 irqpoll reset_devices"
  Modified cmdline:1 irqpoll reset_devices mem=32767K@65536K elfcorehdr=97276K 

.. code-block:: shell

  root@OpenWrt:/# echo c > /proc/sysrq-trigger

After the boot (without going through u-boot), a file ``/proc/vmcore``
should be available which can be saved for further analysis.

Analyzing vmcore
----------------

gdb is usually the correct way to start analyzing coredumps or have
interactive (remote) debugging sessions. But this usually ends like this
when trying to operate on various memory regions:

.. code-block:: shell

  $ gdb-multiarch -q -iex "set auto-load safe-path scripts/gdb/" vmlinux vmcore
  Reading symbols from vmlinux...
  [New process 1]
  [New LWP 2637]
  #0  0xffffffff818b70d7 in native_safe_halt () at ./arch/x86/include/asm/irqflags.h:61
  61      }
  [Current thread is 1 (process 1)]
  (gdb) thread 2
  [Switching to thread 2 (LWP 2637)]
  #0  0xffffffffa032491c in ?? ()
  (gdb) lx-symbols ..
  loading vmlinux
  Python Exception <class 'gdb.MemoryError'> Cannot access memory at address 0xffffffffa00e5358: 
  Error occurred in Python: Cannot access memory at address 0xffffffffa00e5358

The problem here is that GDB expects to go through the system MMU (which
performs the page table walk) or that the correct memory mappings are
declared in the ELF headers. For this dump, nothing like this is
available:

.. code-block:: shell

  $ readelf -l vmcore

  Elf file type is CORE (Core file)
  Entry point 0x0
  There are 5 program headers, starting at offset 64

  Program Headers:
    Type           Offset             VirtAddr           PhysAddr
                   FileSiz            MemSiz              Flags  Align
    NOTE           0x0000000000001000 0x0000000000000000 0x0000000000000000
                   0x0000000000000a58 0x0000000000000a58         0x0
    LOAD           0x0000000000002000 0xffffffff81000000 0x0000000001000000
                   0x0000000001626000 0x0000000001626000  RWE    0x0
    LOAD           0x0000000001628000 0xffff880000001000 0x0000000000001000
                   0x000000000009ec00 0x000000000009ec00  RWE    0x0
    LOAD           0x00000000016c7000 0xffff880000100000 0x0000000000100000
                   0x0000000016f00000 0x0000000016f00000  RWE    0x0
    LOAD           0x00000000185c7000 0xffff88001f000000 0x000000001f000000
                   0x0000000000fdd000 0x0000000000fdd000  RWE    0x0

Other tools like `crash <https://github.com/crash-utility/crash>`__ are
better suited for this task. They can even show how the page is actually
mapped. In our case, the problem is that modules are not using
continuous physical pages (which are mapped by the program headers) but
only virtual address space continuous pages:

.. code-block:: shell

  $ crash vmlinux  vmcore
  [...]
  crash> kmem 0xffffffffa00e5358
  ffffffffa00e5358 (t) cleanup_module+6530 [pppoe] 

     VMAP_AREA         VM_STRUCT                 ADDRESS RANGE                SIZE
  ffff88801598cd80  ffff888015a0ccc0  ffffffffa00e2000 - ffffffffa00e8000    24576

        PAGE       PHYSICAL      MAPPING       INDEX CNT FLAGS
  ffff88801fd6bb00 15aec000                0        0  1 480000000000


  crash> vtop 0xffffffffa00e5358
  VIRTUAL           PHYSICAL        
  ffffffffa00e5358  15aec358        

  PGD DIRECTORY: ffffffff82208000
  PAGE DIRECTORY: 220c067
     PUD: 220cff0 => 220d063
     PMD: 220d800 => 165f1067
     PTE: 165f1728 => 8000000015aec063
    PAGE: 15aec000

        PTE         PHYSICAL  FLAGS
  8000000015aec063  15aec000  (PRESENT|RW|ACCESSED|DIRTY|NX)

        PAGE       PHYSICAL      MAPPING       INDEX CNT FLAGS
  ffff88801fd6bb00 15aec000                0        0  1 480000000000

While the crash tool is not providing the same python scripts as
gdb(-scripts) would, it can still be used to load the module debug
information and extract various useful information:

::

  crash> mod -S ..
       MODULE       NAME                SIZE  OBJECT FILE
  ffffffffa000a6c0  libphy             53248  ../linux-5.4.143/drivers/net/phy/libphy.o 
  ffffffffa0015180  pps_core           16384  ../linux-5.4.143/drivers/pps/pps_core.o 
  ffffffffa001e640  realtek            20480  ../linux-5.4.143/drivers/net/phy/realtek.o 
  ?? Section *UND* not found for symbol ptp_clock_unregister
  ?? Section *UND* not found for symbol ptp_clock_register
  [...]
  ffffffffa00e5340  pppoe              20480  ../linux-5.4.143/drivers/net/ppp/pppoe.o 
  [...]
  ffffffffa03373c0  batman_adv        237568  ../batman-adv-2021.3/net/batman-adv/batman-adv.o


  crash> log
  [...]
  [  280.671070] Oops: 0002 [#1] SMP PTI
  [  280.671500] CPU: 1 PID: 2637 Comm: batctl Kdump: loaded Not tainted 5.4.143 #0
  [  280.672324] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.14.0-2 04/01/2014
  [  280.673261] RIP: 0010:batadv_netlink_set_mesh+0x39/0x327 [batman_adv]
  [  280.674003] Code: 30 48 8b 46 20 48 8b b8 48 01 00 00 48 85 ff 74 23 e8 80 ed ff ff 84 c0 40 0f 95 c6 40 0f b6 f6 49 8d 7c 24 18 e8 b6 eb ff ff <66> c7 04 25 00 00 00 00 17 00 48 8b 43 20 48 8b b8 50 01 00 00 48
  [  280.676024] RSP: 0018:ffffc9000015fa70 EFLAGS: 00010202
  [  280.676639] RAX: 0000000000000001 RBX: ffffc9000015fab8 RCX: ffff888015a35200
  [  280.677448] RDX: 0000607fe0801a88 RSI: 0000000000000001 RDI: ffff88801610b898
  [  280.678258] RBP: ffffc9000015fa88 R08: 0000000000000000 R09: ffff888015a35200
  [  280.679052] R10: 000000000000003c R11: ffffffffa0332160 R12: ffff88801610b880
  [  280.679855] R13: ffff8880160efa14 R14: ffff888016bf9200 R15: 0000000000000000
  [  280.680662] FS:  00007f7a7ba6cd48(0000) GS:ffff88801f500000(0000) knlGS:0000000000000000
  [  280.681585] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  [  280.682261] CR2: 0000000000000000 CR3: 000000001543a001 CR4: 0000000000360ee0
  [  280.683072] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
  [  280.683885] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
  [  280.684697] Call Trace:
  [  280.685018]  genl_family_rcv_msg+0x1ca/0x3e0
  [  280.685536]  genl_rcv_msg+0x43/0x90
  [  280.685971]  ? genl_family_rcv_msg+0x3e0/0x3e0
  [  280.686500]  netlink_rcv_skb+0x4a/0x110
  [  280.686970]  genl_rcv+0x23/0x40
  [  280.687360]  netlink_unicast+0x166/0x1e0
  [  280.687834]  netlink_sendmsg+0x1e1/0x380
  [  280.688312]  ? netlink_unicast+0x1e0/0x1e0
  [  280.688808]  ____sys_sendmsg+0x226/0x250
  [  280.689283]  ? copy_msghdr_from_user+0xbd/0x130
  [  280.689831]  ___sys_sendmsg+0x7a/0xb0
  [  280.690284]  ? ___sys_recvmsg+0x72/0x90
  [  280.690752]  ? __check_object_size+0x4c/0x1a0
  [  280.691272]  ? _copy_to_user+0x2b/0x40
  [  280.691731]  ? move_addr_to_user+0x64/0xb0
  [  280.692235]  __sys_sendmsg+0x40/0x70
  [  280.692676]  __x64_sys_sendmsg+0x1a/0x20
  [  280.693153]  do_syscall_64+0x54/0x370
  [  280.693612]  ? do_page_fault+0x9/0x10
  [  280.694067]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
  [  280.694654] RIP: 0033:0x7f7a7ba4e315
  [  280.695093] Code: c3 8b 07 85 c0 75 24 49 89 fb 48 89 f0 48 89 d7 48 89 ce 4c 89 c2 4d 89 ca 4c 8b 44 24 08 4c 8b 4c 24 10 4c 89 5c 24 08 0f 05 <c3> e9 19 d3 ff ff 41 54 b8 02 00 00 00 49 89 f4 be 00 08 08 00 55
  [  280.697111] RSP: 002b:00007fff6e7665f8 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
  [  280.697981] RAX: ffffffffffffffda RBX: 00007f7a7ba6cd48 RCX: 00007f7a7ba4e315
  [  280.698787] RDX: 0000000000000000 RSI: 00007fff6e766648 RDI: 0000000000000003
  [  280.699592] RBP: 000000000000002e R08: 0000000000000000 R09: 0000000000000000
  [  280.700398] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
  [  280.701198] R13: 000000000000000f R14: 00007f7a7ba6d8e0 R15: 0000000000000000
  [  280.702018] Modules linked in: pppoe ppp_async iptable_nat batman_adv xt_state xt_nat xt_conntrack xt_REDIRECT xt_MASQUERADE xt_FLOWOFFLOAD pppox ppp_generic nf_nat nf_flow_table_hw nf_flow_table nf_conntrack ipt_REJECT cfg80211 xt_time xt_tcpudp xt_multiport xt_mark xt_mac xt_limit xt_comment xt_TCPMSS xt_LOG slhc r8169 nf_reject_ipv4 nf_log_ipv4 nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c iptable_mangle iptable_filter ip_tables forcedeth e1000e crc_ccitt compat bnx2 i2c_dev nf_log_ipv6 nf_log_common ip6table_mangle ip6table_filter ip6_tables ip6t_REJECT x_tables nf_reject_ipv6 ixgbe igb e1000 mdio vfat fat nls_utf8 nls_iso8859_1 nls_cp437 button_hotplug ptp realtek pps_core libphy
  [  280.708381] CR2: 0000000000000000
  [  280.708799] Unregister pv shared memory for cpu 1


  crash> bt -al
  PID: 0      TASK: ffffffff822114c0  CPU: 0   COMMAND: "swapper/0"
   #0 [fffffe0000009e58] crash_nmi_callback at ffffffff81042232
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/./arch/x86/include/asm/paravirt.h: 149
   #1 [fffffe0000009e68] nmi_handle at ffffffff81028056
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/kernel/nmi.c: 144
   #2 [fffffe0000009ea8] do_nmi at ffffffff8102828f
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/kernel/nmi.c: 336
   #3 [fffffe0000009ef0] end_repeat_nmi at ffffffff81a01590
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/entry/entry_64.S: 1688
      [exception RIP: native_safe_halt+23]
      RIP: ffffffff818b70d7  RSP: ffffffff82203e40  RFLAGS: 00000246
      RAX: 0000000000000000  RBX: 0000000000000000  RCX: 0000000000000001
      RDX: 000000000008b6ca  RSI: 0000000000000000  RDI: 0000000000000000
      RBP: ffffffff82203e40   R8: 0000000000000015   R9: 00000000000003cd
      R10: 0000000000000000  R11: 0000000000000073  R12: ffffffff82296e40
      R13: 0000000000000000  R14: 0000000000000000  R15: 0000000000000000
      ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/./arch/x86/include/asm/irqflags.h: 60
  --- <NMI exception stack> ---
   #4 [ffffffff82203e40] native_safe_halt at ffffffff818b70d7
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/./arch/x86/include/asm/irqflags.h: 60
   #5 [ffffffff82203e48] default_idle at ffffffff818b6f79
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/./arch/x86/include/asm/paravirt.h: 144
   #6 [ffffffff82203e58] arch_cpu_idle at ffffffff8102d5d0
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/kernel/process.c: 563
   #7 [ffffffff82203e68] default_idle_call at ffffffff818b7187
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/kernel/sched/idle.c: 95
   #8 [ffffffff82203e78] do_idle at ffffffff810d62bf
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/kernel/sched/idle.c: 155
   #9 [ffffffff82203eb8] cpu_startup_entry at ffffffff810d6438
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/kernel/sched/idle.c: 355
  #10 [ffffffff82203ed0] rest_init at ffffffff818b0764
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/init/main.c: 475
  #11 [ffffffff82203ee0] arch_call_rest_init at ffffffff822cead5
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/init/main.c: 597
  #12 [ffffffff82203ef0] start_kernel at ffffffff822cf03e
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/init/main.c: 811
  #13 [ffffffff82203f28] x86_64_start_reservations at ffffffff822ce421
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/kernel/head64.c: 490
  #14 [ffffffff82203f38] x86_64_start_kernel at ffffffff822ce494
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/kernel/head64.c: 471
  #15 [ffffffff82203f50] secondary_startup_64 at ffffffff810000d4
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/kernel/head_64.S: 241

  PID: 2637   TASK: ffff88801f300d40  CPU: 1   COMMAND: "batctl"
   #0 [ffffc9000015f718] machine_kexec at ffffffff8104ba66
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/./arch/x86/include/asm/mem_encrypt.h: 72
   #1 [ffffc9000015f768] __crash_kexec at ffffffff81120bee
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/kernel/kexec_core.c: 957
   #2 [ffffc9000015f830] crash_kexec at ffffffff81122089
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/./include/linux/compiler.h: 292
   #3 [ffffc9000015f850] oops_end at ffffffff81027d92
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/kernel/dumpstack.c: 334
   #4 [ffffc9000015f878] no_context at ffffffff810542bf
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/mm/fault.c: 848
   #5 [ffffc9000015f8e0] __bad_area_nosemaphore.constprop.33 at ffffffff8105451b
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/mm/fault.c: 934
   #6 [ffffc9000015f920] bad_area_nosemaphore at ffffffff8105477e
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/mm/fault.c: 941
   #7 [ffffc9000015f930] __do_page_fault at ffffffff81054afe
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/mm/fault.c: 1298
   #8 [ffffc9000015f998] do_page_fault at ffffffff81054cb9
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/./include/linux/context_tracking.h: 89
   #9 [ffffc9000015f9a8] do_async_page_fault at ffffffff8104f98b
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/kernel/kvm.c: 254
  #10 [ffffc9000015f9c0] async_page_fault at ffffffff81a011c4
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/arch/x86/entry/entry_64.S: 1206
      [exception RIP: batadv_netlink_set_mesh+57]
      RIP: ffffffffa032491c  RSP: ffffc9000015fa70  RFLAGS: 00010202
      RAX: 0000000000000001  RBX: ffffc9000015fab8  RCX: ffff888015a35200
      RDX: 0000607fe0801a88  RSI: 0000000000000001  RDI: ffff88801610b898
      RBP: ffffc9000015fa88   R8: 0000000000000000   R9: ffff888015a35200
      R10: 000000000000003c  R11: ffffffffa0332160  R12: ffff88801610b880
      R13: ffff8880160efa14  R14: ffff888016bf9200  R15: 0000000000000000
      ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
      ./build_dir/target-x86_64_musl/linux-x86_64/batman-adv-2021.3/net/batman-adv/netlink.c: 448


  crash> print batadv_netlink_set_mesh+57
  $1 = (int (*)(struct sk_buff *, struct genl_info *)) 0xffffffffa032491c <batadv_netlink_set_mesh+57>
  crash> kmem ffffffffa032491c
  ffffffffa032491c (t) batadv_netlink_set_mesh+57 [batman_adv] ./build_dir/target-x86_64_musl/linux-x86_64/batman-adv-2021.3/net/batman-adv/netlink.c: 448

     VMAP_AREA         VM_STRUCT                 ADDRESS RANGE                SIZE
  ffff88801598c700  ffff888015a0c480  ffffffffa0311000 - ffffffffa034c000   241664

        PAGE       PHYSICAL      MAPPING       INDEX CNT FLAGS
  ffff88801fcb3d80 12cf6000                0        0  1 480000000000


  crash> dis -s batadv_netlink_set_mesh+57
  FILE: ./build_dir/target-x86_64_musl/linux-x86_64/batman-adv-2021.3/net/batman-adv/netlink.c
  LINE: 448

    443           if (info->attrs[BATADV_ATTR_AGGREGATED_OGMS_ENABLED]) {
    444                   attr = info->attrs[BATADV_ATTR_AGGREGATED_OGMS_ENABLED];
    445   
    446                   atomic_set(&bat_priv->aggregated_ogms, !!nla_get_u8(attr));
    447                   attr = NULL;
  * 448                   attr->nla_len = 23;
    449           }
