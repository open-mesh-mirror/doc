.. SPDX-License-Identifier: GPL-2.0

Crashdumps with kexec
=====================

:doc:`Stack traces <Crashlog_with_pstore>` are a nice way to have a first
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
system” as ``/proc/vmcore`` (in ELF format)

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
to save the ``/proc/vmcore`` to the filesystem before rebooting the system
again to return to the normal environment.

Let us check the setup on OpenWrt without using the kdump packages.
First step is to enable the KEXEC specific options in OpenWrt’s .config.
The boot cmdline can also directly set up during the image build (or
later changed under OpenWrt):

.. code-block:: diff

  diff --git a/.config b/.config
  --- a/.config
  +++ b/.config
  @@ -222,7 +222,8 @@ CONFIG_KERNEL_KALLSYMS=y
   # CONFIG_KERNEL_FTRACE is not set
   CONFIG_KERNEL_DEBUG_KERNEL=y
   CONFIG_KERNEL_DEBUG_INFO=y
  -CONFIG_KERNEL_DEBUG_INFO_REDUCED=y
  +# CONFIG_KERNEL_DEBUG_INFO_BTF is not set
  +# CONFIG_KERNEL_DEBUG_INFO_REDUCED is not set
   CONFIG_KERNEL_FRAME_WARN=2048
   # CONFIG_KERNEL_DEBUG_VIRTUAL is not set
   # CONFIG_KERNEL_DYNAMIC_DEBUG is not set
  @@ -598,7 +598,7 @@ CONFIG_KERNEL_PRINTK_TIME=y
   # CONFIG_KERNEL_SLUB_DEBUG is not set
   # CONFIG_KERNEL_SLABINFO is not set
   # CONFIG_KERNEL_PROC_PAGE_MONITOR is not set
  -# CONFIG_KERNEL_KEXEC is not set
  +CONFIG_KERNEL_KEXEC=y
   # CONFIG_USE_RFKILL is not set
   # CONFIG_USE_SPARSE is not set
   # CONFIG_KERNEL_DEVTMPFS is not set
  @@ -2000,7 +2000,9 @@ CONFIG_PACKAGE_wifi-scripts=y
   #
   # Libraries
   #
  +# CONFIG_PACKAGE_libncurses-dev is not set
   # CONFIG_PACKAGE_libxml2-dev is not set
  +# CONFIG_PACKAGE_zlib-dev is not set
   # end of Libraries

   # CONFIG_PACKAGE_ar is not set
  @@ -3442,7 +3444,13 @@ CONFIG_PACKAGE_libustream-mbedtls=y
   # CONFIG_PACKAGE_linux-atm is not set
   # CONFIG_PACKAGE_musl-fts is not set
   # CONFIG_PACKAGE_terminfo is not set
  -# CONFIG_PACKAGE_zlib is not set
  +CONFIG_PACKAGE_zlib=y
  +
  +#
  +# Configuration
  +#
  +# CONFIG_ZLIB_OPTIMIZE_SPEED is not set
  +# end of Configuration
   # end of Libraries

   #
  @@ -3867,6 +3875,16 @@ CONFIG_PACKAGE_uboot-envtools=y
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
   # CONFIG_PACKAGE_libxml2-utils is not set
   # CONFIG_PACKAGE_logger is not set
  diff --git a/target/linux/x86/image/Makefile b/target/linux/x86/image/Makefile
  --- a/target/linux/x86/image/Makefile
  +++ b/target/linux/x86/image/Makefile
  @@ -9,7 +9,7 @@ GRUB2_VARIANT =
   GRUB_TERMINALS =
   GRUB_SERIAL_CONFIG =
   GRUB_TERMINAL_CONFIG =
  -GRUB_CONSOLE_CMDLINE =
  +GRUB_CONSOLE_CMDLINE = nokaslr crashkernel=128M

   ifneq ($(CONFIG_GRUB_CONSOLE),)
     GRUB_CONSOLE_CMDLINE += console=tty1

When the system is booted, the reserved memory for the crash kernel
should be visible:

.. code-block:: sh

  root@OpenWrt:/# cat /proc/iomem |grep -e 'System RAM' -e 'Crash kernel'
  00001000-0009fbff : System RAM
  00100000-1ffdcfff : System RAM
    17000000-1effffff : Crash kernel

The system kernel must now be loaded in the “Crash kernel” region so the
panic handler can boot it on demand.

.. code-block:: sh

  root@OpenWrt:/# cat /proc/iomem |grep -e 'System RAM' -e 'Crash kernel'
  00001000-0009fbff : System RAM
  00100000-1ffdcfff : System RAM
    17000000-1effffff : Crash kernel

.. code-block:: sh

  root@OpenWrt:/# kexec -p /boot/vmlinuz --reuse-cmdline --append '1 irqpoll nr_cpus=1 reset_devices'

To test the setup, a crash can be simulated using various mechanisms.
For example using sysrq:

.. code-block:: sh

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

  diff --git a/target/linux/generic/config-6.6 b/target/linux/generic/config-6.6
  --- a/target/linux/generic/config-6.6
  +++ b/target/linux/generic/config-6.6
  @@ -2210,7 +2210,7 @@ CONFIG_GPIO_SYSFS=y
   # CONFIG_HAMACHI is not set
   # CONFIG_HAMRADIO is not set
   # CONFIG_HAPPYMEAL is not set
  -CONFIG_HARDENED_USERCOPY=y
  +# CONFIG_HARDENED_USERCOPY is not set
   CONFIG_HARDEN_BRANCH_HISTORY=y
   # CONFIG_HARDLOCKUP_DETECTOR is not set
   # CONFIG_HAVE_ARM_ARCH_TIMER is not set
  --- a/target/linux/ath79/dts/xxx_xxx.dts
  +++ b/target/linux/ath79/dts/xxx_xxx.dts
  @@ -12,5 +12,5 @@

      chosen {
  -       bootargs = "console=ttyS0,115200n8";
  +       bootargs = "console=ttyS0,115200n8 crashkernel=32M@0x01000000";
      };

      aliases {

This should be visible when booting this device:

.. code-block:: sh

  root@OpenWrt:/# cat /proc/iomem |grep -e 'System RAM' -e 'Crash kernel'
  00000000-07ffffff : System RAM
    01000000-02ffffff : Crash kernel

The device should of course also have the kexec support enabled in
OpenWrt’s .config

.. code-block:: diff

  diff --git a/.config b/.config
  --- a/.config
  +++ b/.config
  @@ -222,7 +222,8 @@ CONFIG_KERNEL_KALLSYMS=y
   # CONFIG_KERNEL_FTRACE is not set
   CONFIG_KERNEL_DEBUG_KERNEL=y
   CONFIG_KERNEL_DEBUG_INFO=y
  -CONFIG_KERNEL_DEBUG_INFO_REDUCED=y
  +# CONFIG_KERNEL_DEBUG_INFO_BTF is not set
  +# CONFIG_KERNEL_DEBUG_INFO_REDUCED is not set
   CONFIG_KERNEL_FRAME_WARN=2048
   # CONFIG_KERNEL_DEBUG_VIRTUAL is not set
   # CONFIG_KERNEL_DYNAMIC_DEBUG is not set
  @@ -598,7 +598,7 @@ CONFIG_KERNEL_PRINTK_TIME=y
   # CONFIG_KERNEL_SLUB_DEBUG is not set
   # CONFIG_KERNEL_SLABINFO is not set
   # CONFIG_KERNEL_PROC_PAGE_MONITOR is not set
  -# CONFIG_KERNEL_KEXEC is not set
  +CONFIG_KERNEL_KEXEC=y
   # CONFIG_USE_RFKILL is not set
   # CONFIG_USE_SPARSE is not set
   # CONFIG_KERNEL_DEVTMPFS is not set
  @@ -2000,7 +2000,9 @@ CONFIG_PACKAGE_wifi-scripts=y
   #
   # Libraries
   #
  +# CONFIG_PACKAGE_libncurses-dev is not set
   # CONFIG_PACKAGE_libxml2-dev is not set
  +# CONFIG_PACKAGE_zlib-dev is not set
   # end of Libraries

   # CONFIG_PACKAGE_ar is not set
  @@ -3442,7 +3444,13 @@ CONFIG_PACKAGE_libustream-mbedtls=y
   # CONFIG_PACKAGE_linux-atm is not set
   # CONFIG_PACKAGE_musl-fts is not set
   # CONFIG_PACKAGE_terminfo is not set
  -# CONFIG_PACKAGE_zlib is not set
  +CONFIG_PACKAGE_zlib=y
  +
  +#
  +# Configuration
  +#
  +# CONFIG_ZLIB_OPTIMIZE_SPEED is not set
  +# end of Configuration
   # end of Libraries

   #
  @@ -3867,6 +3875,16 @@ CONFIG_PACKAGE_uboot-envtools=y
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
   # CONFIG_PACKAGE_libxml2-utils is not set
   # CONFIG_PACKAGE_logger is not set

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

  diff --git a/target/linux/ath79/config-6.6 b/target/linux/ath79/config-6.6
  --- a/target/linux/ath79/config-6.6
  +++ b/target/linux/ath79/config-6.6
  @@ -118,7 +118,7 @@ CONFIG_MIPS_CLOCK_VSYSCALL=y
   CONFIG_MIPS_CMDLINE_FROM_DTB=y
   CONFIG_MIPS_L1_CACHE_SHIFT=5
   # CONFIG_MIPS_NO_APPENDED_DTB is not set
  -CONFIG_MIPS_RAW_APPENDED_DTB=y
  +# CONFIG_MIPS_RAW_APPENDED_DTB is not set
   CONFIG_MIPS_SPRAM=y
   CONFIG_MMU_LAZY_TLB_REFCOUNT=y
   CONFIG_MODULES_USE_ELF_REL=y
  @@ -220,3 +220,9 @@ CONFIG_TINY_SRCU=y
   CONFIG_USB_SUPPORT=y
   CONFIG_USE_OF=y
   CONFIG_ZBOOT_LOAD_ADDRESS=0x0
  +
  +CONFIG_MIPS_ELF_APPENDED_DTB=y
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

.. code-block:: sh

  $ LXBASE=./build_dir/target-mips_24kc_musl/linux-ath79_generic
  $ cp "$LXBASE"/vmlinux.elf vmlinux.elf
  $ mips-linux-gnu-strip vmlinux.elf
  $ mips-linux-gnu-objcopy --update-section .appended_dtb="$LXBASE"/image-xxx_xxx.dtb vmlinux.elf

The system kernel must now be loaded in the “Crash kernel” region so the
panic handler can boot it on demand.

.. code-block:: sh

  root@OpenWrt:/# kexec -p /tmp/vmlinux.elf --command-line "" --append "$(cat /proc/cmdline) 1 irqpoll reset_devices"
  Modified cmdline:1 irqpoll reset_devices mem=32767K@65536K elfcorehdr=97276K

.. code-block:: sh

  root@OpenWrt:/# echo c > /proc/sysrq-trigger

After the boot (without going through u-boot), a file ``/proc/vmcore``
should be available which can be saved for further analysis.

Analyzing vmcore
----------------

gdb is usually the correct way to start analyzing coredumps or have
interactive (remote) debugging sessions. But this usually ends like this
when trying to operate on various memory regions:

.. code-block:: sh

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
  Python Exception <class 'gdb.MemoryError'> Cannot access memory at address 0xffffffffa073efa2: 
  Error occurred in Python: Cannot access memory at address 0xffffffffa073efa2

The problem here is that GDB expects to go through the system MMU (which
performs the page table walk) or that the correct memory mappings are
declared in the ELF headers. For this dump, nothing like this is
available:

.. code-block:: sh

  $ readelf -l vmcore

  Elf file type is CORE (Core file)
  Entry point 0x0
  There are 5 program headers, starting at offset 64

  Program Headers:
    Type           Offset             VirtAddr           PhysAddr
                   FileSiz            MemSiz              Flags  Align
    NOTE           0x0000000000001000 0x0000000000000000 0x0000000000000000
                   0x0000000000000de8 0x0000000000000de8         0x4
    LOAD           0x0000000000002000 0xffffffff81000000 0x0000000001000000
                   0x0000000001a26000 0x0000000001a26000  RWE    0x0
    LOAD           0x0000000001a28000 0xffff888000001000 0x0000000000001000
                   0x000000000009ec00 0x000000000009ec00  RWE    0x0
    LOAD           0x0000000001ac7000 0xffff888000100000 0x0000000000100000
                   0x0000000036f00000 0x0000000036f00000  RWE    0x0
    LOAD           0x00000000389c7000 0xffff88803f000000 0x000000003f000000
                   0x0000000000fe0000 0x0000000000fe0000  RWE    0x0

Other tools like `crash <https://github.com/crash-utility/crash>`__ or
`drgn <https://drgn.readthedocs.io/>`__ are better suited for this task.

crash
~~~~~

crash can even show how the page is actually mapped. In our case, the
problem is that modules are not using continuous physical pages (which
are mapped by the program headers) but only virtual address space
continuous pages:

.. code-block:: sh

  $ crash ../vmlinux.debug  vmcore
  [...]
  crash> kmem 0xffffffffa073efa2
  ffffffffa073efa2 (t) batadv_netlink_set_mesh+0x32 [batman_adv] 

     VMAP_AREA         VM_STRUCT                 ADDRESS RANGE                SIZE
  ffff888003c20e58  ffff8880063d6880  ffffffffa0723000 - ffffffffa0753000   196608

        PAGE       PHYSICAL      MAPPING       INDEX CNT FLAGS
  ffff8880361ec480  7b12000                0        0  1 80000000000

While the crash tool is not providing the same python scripts as
gdb(-scripts) would, it can still be used to load the module debug
information and extract various useful information:

.. code-block:: sh

  crash> mod -S ..
       MODULE       NAME                   TEXT_BASE         SIZE  OBJECT FILE
  ffffffffa02116c0  libphy              ffffffffa0201000   114688  ../linux-6.6.73/drivers/net/phy/libphy.o 
  ffffffffa0223080  nls_cp437           ffffffffa0221000    16384  ../linux-6.6.73/fs/nls/nls_cp437.o 
  ffffffffa022e080  nls_iso8859_1       ffffffffa022c000    12288  ../linux-6.6.73/fs/nls/nls_iso8859-1.o
  [...]
  ffffffffa0757d00  batman_adv          ffffffffa0723000   434176  ../batman-adv-2024.3/net/batman-adv/batman-adv.o
  [...]


  crash> log
  [...]
  [   48.631089] Oops: 0002 [#1] SMP NOPTI
  [   48.631561] CPU: 0 PID: 2666 Comm: batctl Kdump: loaded Tainted: G           O       6.6.73 #0
  [   48.632381] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
  [   48.633268] RIP: 0010:batadv_netlink_set_mesh+0x32/0x2b0 [batman_adv]
  [   48.633949] Code: 53 48 89 f3 4c 8b 66 30 48 8b 46 20 48 8b b8 48 01 00 00 48 85 ff 74 1c e8 7b ea ff ff 84 c0 0f 95 c0 0f b6 c0 41 89 44 24 20 <66> c7 04 25 00 00 00 00 17 00 48 8b 43 20 48 8b b8 50 01 00 00 48
  [   48.635712] RSP: 0018:ffffc9000017b9f8 EFLAGS: 00010246
  [   48.636291] RAX: 0000000000000000 RBX: ffffc9000017ba28 RCX: ffff888005c6ce00
  [   48.637003] RDX: 000000000000000b RSI: ffffc9000017ba28 RDI: ffff88800458dd5c
  [   48.637716] RBP: ffffc9000017ba10 R08: 0000000000000000 R09: 0000000000000000
  [   48.638439] R10: 0000000000000000 R11: ffffffff825086a8 R12: ffff8880060de940
  [   48.639173] R13: ffff888005c6ce00 R14: ffff888005808c00 R15: ffffc9000017bb20
  [   48.639891] FS:  00007f994ff64b28(0000) GS:ffff88803fc00000(0000) knlGS:0000000000000000
  [   48.640677] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  [   48.641299] CR2: 0000000000000000 CR3: 0000000006316000 CR4: 00000000000006f0
  [   48.642042] Call Trace:
  [   48.642434]  <TASK>
  [   48.642794]  ? show_regs+0x60/0x70
  [   48.643251]  ? __die+0x1f/0x70
  [   48.643679]  ? page_fault_oops+0x14c/0x430
  [   48.644177]  ? batadv_netlink_set_mesh+0x32/0x2b0 [batman_adv]
  [   48.644815]  ? search_bpf_extables+0xd/0x60
  [   48.645317]  ? batadv_netlink_set_mesh+0x32/0x2b0 [batman_adv]
  [   48.645949]  ? search_exception_tables+0x5b/0x60
  [   48.646490]  ? fixup_exception+0x22/0x320
  [   48.646981]  ? kernelmode_fixup_or_oops.constprop.0+0x5a/0x70
  [   48.647595]  ? __bad_area_nosemaphore.constprop.0+0x152/0x220
  [   48.648214]  ? find_vma+0x20/0x30
  [   48.648686]  ? bad_area_nosemaphore+0xe/0x20
  [   48.649193]  ? exc_page_fault+0x1f1/0x620
  [   48.649677]  ? asm_exc_page_fault+0x27/0x30
  [   48.650182]  ? batadv_netlink_set_mesh+0x32/0x2b0 [batman_adv]
  [   48.650813]  ? batadv_netlink_set_mesh+0x25/0x2b0 [batman_adv]
  [   48.651434]  genl_family_rcv_msg_doit+0xbc/0x100
  [   48.651964]  genl_rcv_msg+0x15d/0x270
  [   48.652419]  ? __pfx_batadv_pre_doit+0x10/0x10 [batman_adv]
  [   48.653016]  ? __pfx_batadv_netlink_set_mesh+0x10/0x10 [batman_adv]
  [   48.653666]  ? __pfx_batadv_post_doit+0x10/0x10 [batman_adv]
  [   48.654287]  ? __pfx_genl_rcv_msg+0x10/0x10
  [   48.654775]  netlink_rcv_skb+0x58/0x100
  [   48.655237]  genl_rcv+0x23/0x40
  [   48.655650]  netlink_unicast+0x1f3/0x2d0
  [   48.656115]  netlink_sendmsg+0x208/0x440
  [   48.656562]  ____sys_sendmsg+0x244/0x2e0
  [   48.657013]  ? copy_msghdr_from_user+0x5d/0x80
  [   48.657501]  ___sys_sendmsg+0x7a/0xc0
  [   48.657934]  ? __mod_memcg_lruvec_state+0x49/0xa0
  [   48.658451]  ? set_ptes.isra.0+0x23/0xa0
  [   48.658919]  ? __handle_mm_fault+0x67d/0xbd0
  [   48.659390]  __sys_sendmsg+0x46/0xa0
  [   48.659813]  ? irqentry_exit+0x1d/0x30
  [   48.660243]  __x64_sys_sendmsg+0x18/0x20
  [   48.660681]  x64_sys_call+0x1709/0x1c90
  [   48.661111]  do_syscall_64+0x3d/0x90
  [   48.661516]  entry_SYSCALL_64_after_hwframe+0x78/0xe2
  [   48.662031] RIP: 0033:0x7f994ff42837
  [   48.662428] Code: c3 8b 07 85 c0 75 24 49 89 fb 48 89 f0 48 89 d7 48 89 ce 4c 89 c2 4d 89 ca 4c 8b 44 24 08 4c 8b 4c 24 10 4c 89 5c 24 08 0f 05 <c3> e9 5a cb ff ff 41 54 b8 02 00 00 00 55 48 89 f5 be 00 88 08 00
  [   48.664044] RSP: 002b:00007ffe0724c4c8 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
  [   48.664736] RAX: ffffffffffffffda RBX: 000000000000002e RCX: 00007f994ff42837
  [   48.665396] RDX: 0000000000000000 RSI: 00007ffe0724c510 RDI: 0000000000000003
  [   48.666068] RBP: 00007f994ff64b28 R08: 0000000000000000 R09: 0000000000000000
  [   48.666736] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffe0724c9c0
  [   48.667395] R13: 0000000000405a60 R14: 000000000000000f R15: 00007ffe0724cc00
  [   48.668051]  </TASK>
  [   48.668353] Modules linked in: pppoe ppp_async nft_fib_inet nf_flow_table_inet i915 batman_adv(O) video pppox ppp_generic nft_reject_ipv6 nft_reject_ipv4 nft_reject_inet nft_reject nft_redir nft_quota nft_numgen nft_nat nft_masq nft_log nft_limit nft_hash nft_flow_offload nft_fib_ipv6 nft_fib_ipv4 nft_fib nft_ct nft_chain_nat nf_tables nf_nat nf_flow_table nf_conntrack cfg80211(O) wmi slhc r8169 nfnetlink nf_reject_ipv6 nf_reject_ipv4 nf_log_syslog nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c forcedeth e1000e drm_display_helper drm_buddy crc_ccitt compat(O) bnx2 i2c_dev dwmac_intel dwmac_generic stmmac_platform stmmac ixgbe e1000 amd_xgbe mdio_devres mdio nls_utf8 pcs_xpcs ena nls_iso8859_1 nls_cp437 igb igc vfat fat button_hotplug(O) tg3 realtek phylink mii libphy
  [   48.673848] CR2: 0000000000000000



  crash> bt -al
  PID: 2666     TASK: ffff888006454e00  CPU: 0    COMMAND: "batctl"
   #0 [ffffc9000017b6a0] machine_kexec at ffffffff810681a8
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/arch/x86/kernel/machine_kexec_64.c: 394
   #1 [ffffc9000017b6f8] __crash_kexec at ffffffff8117e78c
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/./include/linux/atomic/atomic-arch-fallback.h: 511
   #2 [ffffc9000017b7b8] crash_kexec at ffffffff81180167
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/./arch/x86/include/asm/atomic.h: 28
   #3 [ffffc9000017b7c8] oops_end at ffffffff8103a6a2
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/arch/x86/kernel/dumpstack.c: 362
   #4 [ffffc9000017b7f0] page_fault_oops at ffffffff81071f10
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/arch/x86/mm/fault.c: 710
   #5 [ffffc9000017b870] kernelmode_fixup_or_oops.constprop.0 at ffffffff8107223a
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/arch/x86/mm/fault.c: 731
   #6 [ffffc9000017b898] __bad_area_nosemaphore.constprop.0 at ffffffff810723b2
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/arch/x86/mm/fault.c: 779
   #7 [ffffc9000017b8e0] bad_area_nosemaphore at ffffffff810724fe
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/arch/x86/mm/fault.c: 827
   #8 [ffffc9000017b8f0] exc_page_fault at ffffffff81a7e2a1
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/arch/x86/mm/fault.c: 1432
   #9 [ffffc9000017b940] asm_exc_page_fault at ffffffff81c00c27
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/./arch/x86/include/asm/idtentry.h: 608
      [exception RIP: batadv_netlink_set_mesh+0x32]
      RIP: ffffffffa073efa2  RSP: ffffc9000017b9f8  RFLAGS: 00010246
      RAX: 0000000000000000  RBX: ffffc9000017ba28  RCX: ffff888005c6ce00
      RDX: 000000000000000b  RSI: ffffc9000017ba28  RDI: ffff88800458dd5c
      RBP: ffffc9000017ba10   R8: 0000000000000000   R9: 0000000000000000
      R10: 0000000000000000  R11: ffffffff825086a8  R12: ffff8880060de940
      R13: ffff888005c6ce00  R14: ffff888005808c00  R15: ffffc9000017bb20
      ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
      ./build_dir/target-x86_64_musl/linux-x86_64/batman-adv-2024.3/net/batman-adv/netlink.c: 447
  #10 [ffffc9000017ba18] genl_family_rcv_msg_doit at ffffffff818f4b5c
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/net/netlink/genetlink.c: 971
  #11 [ffffc9000017baa0] genl_rcv_msg at ffffffff818f528d
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/net/netlink/genetlink.c: 1051
  #12 [ffffc9000017bb18] netlink_rcv_skb at ffffffff818f38e8
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/net/netlink/af_netlink.c: 2537
  #13 [ffffc9000017bbe0] genl_rcv at ffffffff818f4723
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/net/netlink/genetlink.c: 1076
  #14 [ffffc9000017bbf8] netlink_unicast at ffffffff818f2e83
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/./include/linux/skbuff.h: 1229
  #15 [ffffc9000017bc40] netlink_sendmsg at ffffffff818f3178
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/net/netlink/af_netlink.c: 1891
  #16 [ffffc9000017bcb0] ____sys_sendmsg at ffffffff8186ab44
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/net/socket.c: 730
  #17 [ffffc9000017bd28] ___sys_sendmsg at ffffffff8186c62a
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/net/socket.c: 2651
  #18 [ffffc9000017be80] __sys_sendmsg at ffffffff8186ca06
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/net/socket.c: 2678
  #19 [ffffc9000017bf18] __x64_sys_sendmsg at ffffffff8186ca88
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/net/socket.c: 2685
  #20 [ffffc9000017bf28] x64_sys_call at ffffffff81003c49
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/arch/x86/entry/syscall_64.c: 33
  #21 [ffffc9000017bf38] do_syscall_64 at ffffffff81a794bd
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/arch/x86/entry/common.c: 51
  #22 [ffffc9000017bf50] entry_SYSCALL_64_after_hwframe at ffffffff81c00130
      ./build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/arch/x86/entry/entry_64.S: 121
      RIP: 00007f994ff42837  RSP: 00007ffe0724c4c8  RFLAGS: 00000246
      RAX: ffffffffffffffda  RBX: 000000000000002e  RCX: 00007f994ff42837
      RDX: 0000000000000000  RSI: 00007ffe0724c510  RDI: 0000000000000003
      RBP: 00007f994ff64b28   R8: 0000000000000000   R9: 0000000000000000
      R10: 0000000000000000  R11: 0000000000000246  R12: 00007ffe0724c9c0
      R13: 0000000000405a60  R14: 000000000000000f  R15: 00007ffe0724cc00
      ORIG_RAX: 000000000000002e  CS: 0033  SS: 002b


  crash> print batadv_netlink_set_mesh+0x32
  $1 = (int (*)(struct sk_buff *, struct genl_info *)) 0xffffffffa073efa2 <batadv_netlink_set_mesh+50>
  crash> kmem 0xffffffffa073efa2
  ffffffffa073efa2 (t) batadv_netlink_set_mesh+0x32 [batman_adv] ./build_dir/target-x86_64_musl/linux-x86_64/batman-adv-2024.3/net/batman-adv/netlink.c: 447

     VMAP_AREA         VM_STRUCT                 ADDRESS RANGE                SIZE
  ffff888003c20e58  ffff8880063d6880  ffffffffa0723000 - ffffffffa0753000   196608

        PAGE       PHYSICAL      MAPPING       INDEX CNT FLAGS
  ffff8880361ec480  7b12000                0        0  1 8000000000


  crash> dis -s batadv_netlink_set_mesh+50
  FILE: ./build_dir/target-x86_64_musl/linux-x86_64/batman-adv-2024.3/net/batman-adv/netlink.c
  LINE: 447

    442           if (info->attrs[BATADV_ATTR_AGGREGATED_OGMS_ENABLED]) {
    443                   attr = info->attrs[BATADV_ATTR_AGGREGATED_OGMS_ENABLED];
    444   
    445                   atomic_set(&bat_priv->aggregated_ogms, !!nla_get_u8(attr));
    446                   attr = NULL;
  * 447                   attr->nla_len = 23;
    448           }

drgn
~~~~

drgn is actually a highly programmable debugger - with emphasis on (but
not limited to) retro-active poking in the program state and read-only
debugging. Its interactive shell is actually a python interpreter and
has to be used like one:

.. code-block:: sh

  $ drgn -c  vmcore -s ../vmlinux.debug -s ../batman-adv-2024.3/.pkgdir/kmod-batman-adv/lib/modules/6.6.73/batman-adv.ko
  [...]
  >>> print_dmesg()
  [   48.631089] Oops: 0002 [#1] SMP NOPTI
  [   48.631561] CPU: 0 PID: 2666 Comm: batctl Kdump: loaded Tainted: G           O       6.6.73 #0
  [   48.632381] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
  [   48.633268] RIP: 0010:batadv_netlink_set_mesh+0x32/0x2b0 [batman_adv]
  [   48.633949] Code: 53 48 89 f3 4c 8b 66 30 48 8b 46 20 48 8b b8 48 01 00 00 48 85 ff 74 1c e8 7b ea ff ff 84 c0 0f 95 c0 0f b6 c0 41 89 44 24 20 <66> c7 04 25 00 00 00 00 17 00 48 8b 43 20 48 8b b8 50 01 00 00 48
  [   48.635712] RSP: 0018:ffffc9000017b9f8 EFLAGS: 00010246
  [   48.636291] RAX: 0000000000000000 RBX: ffffc9000017ba28 RCX: ffff888005c6ce00
  [   48.637003] RDX: 000000000000000b RSI: ffffc9000017ba28 RDI: ffff88800458dd5c
  [   48.637716] RBP: ffffc9000017ba10 R08: 0000000000000000 R09: 0000000000000000
  [   48.638439] R10: 0000000000000000 R11: ffffffff825086a8 R12: ffff8880060de940
  [   48.639173] R13: ffff888005c6ce00 R14: ffff888005808c00 R15: ffffc9000017bb20
  [   48.639891] FS:  00007f994ff64b28(0000) GS:ffff88803fc00000(0000) knlGS:0000000000000000
  [   48.640677] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  [   48.641299] CR2: 0000000000000000 CR3: 0000000006316000 CR4: 00000000000006f0
  [   48.642042] Call Trace:
  [   48.642434]  <TASK>
  [   48.642794]  ? show_regs+0x60/0x70
  [   48.643251]  ? __die+0x1f/0x70
  [   48.643679]  ? page_fault_oops+0x14c/0x430
  [   48.644177]  ? batadv_netlink_set_mesh+0x32/0x2b0 [batman_adv]
  [   48.644815]  ? search_bpf_extables+0xd/0x60
  [   48.645317]  ? batadv_netlink_set_mesh+0x32/0x2b0 [batman_adv]
  [   48.645949]  ? search_exception_tables+0x5b/0x60
  [   48.646490]  ? fixup_exception+0x22/0x320
  [   48.646981]  ? kernelmode_fixup_or_oops.constprop.0+0x5a/0x70
  [   48.647595]  ? __bad_area_nosemaphore.constprop.0+0x152/0x220
  [   48.648214]  ? find_vma+0x20/0x30
  [   48.648686]  ? bad_area_nosemaphore+0xe/0x20
  [   48.649193]  ? exc_page_fault+0x1f1/0x620
  [   48.649677]  ? asm_exc_page_fault+0x27/0x30
  [   48.650182]  ? batadv_netlink_set_mesh+0x32/0x2b0 [batman_adv]
  [   48.650813]  ? batadv_netlink_set_mesh+0x25/0x2b0 [batman_adv]
  [   48.651434]  genl_family_rcv_msg_doit+0xbc/0x100
  [   48.651964]  genl_rcv_msg+0x15d/0x270
  [   48.652419]  ? __pfx_batadv_pre_doit+0x10/0x10 [batman_adv]
  [   48.653016]  ? __pfx_batadv_netlink_set_mesh+0x10/0x10 [batman_adv]
  [   48.653666]  ? __pfx_batadv_post_doit+0x10/0x10 [batman_adv]
  [   48.654287]  ? __pfx_genl_rcv_msg+0x10/0x10
  [   48.654775]  netlink_rcv_skb+0x58/0x100
  [   48.655237]  genl_rcv+0x23/0x40
  [   48.655650]  netlink_unicast+0x1f3/0x2d0
  [   48.656115]  netlink_sendmsg+0x208/0x440
  [   48.656562]  ____sys_sendmsg+0x244/0x2e0
  [   48.657013]  ? copy_msghdr_from_user+0x5d/0x80
  [   48.657501]  ___sys_sendmsg+0x7a/0xc0
  [   48.657934]  ? __mod_memcg_lruvec_state+0x49/0xa0
  [   48.658451]  ? set_ptes.isra.0+0x23/0xa0
  [   48.658919]  ? __handle_mm_fault+0x67d/0xbd0
  [   48.659390]  __sys_sendmsg+0x46/0xa0
  [   48.659813]  ? irqentry_exit+0x1d/0x30
  [   48.660243]  __x64_sys_sendmsg+0x18/0x20
  [   48.660681]  x64_sys_call+0x1709/0x1c90
  [   48.661111]  do_syscall_64+0x3d/0x90
  [   48.661516]  entry_SYSCALL_64_after_hwframe+0x78/0xe2
  [   48.662031] RIP: 0033:0x7f994ff42837
  [   48.662428] Code: c3 8b 07 85 c0 75 24 49 89 fb 48 89 f0 48 89 d7 48 89 ce 4c 89 c2 4d 89 ca 4c 8b 44 24 08 4c 8b 4c 24 10 4c 89 5c 24 08 0f 05 <c3> e9 5a cb ff ff 41 54 b8 02 00 00 00 55 48 89 f5 be 00 88 08 00
  [   48.664044] RSP: 002b:00007ffe0724c4c8 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
  [   48.664736] RAX: ffffffffffffffda RBX: 000000000000002e RCX: 00007f994ff42837
  [   48.665396] RDX: 0000000000000000 RSI: 00007ffe0724c510 RDI: 0000000000000003
  [   48.666068] RBP: 00007f994ff64b28 R08: 0000000000000000 R09: 0000000000000000
  [   48.666736] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffe0724c9c0
  [   48.667395] R13: 0000000000405a60 R14: 000000000000000f R15: 00007ffe0724cc00
  [   48.668051]  </TASK>
  [   48.668353] Modules linked in: pppoe ppp_async nft_fib_inet nf_flow_table_inet i915 batman_adv(O) video pppox ppp_generic nft_reject_ipv6 nft_reject_ipv4 nft_reject_inet nft_reject nft_redir nft_quota nft_numgen nft_nat nft_masq nft_log nft_limit nft_hash nft_flow_offload nft_fib_ipv6 nft_fib_ipv4 nft_fib nft_ct nft_chain_nat nf_tables nf_nat nf_flow_table nf_conntrack cfg80211(O) wmi slhc r8169 nfnetlink nf_reject_ipv6 nf_reject_ipv4 nf_log_syslog nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c forcedeth e1000e drm_display_helper drm_buddy crc_ccitt compat(O) bnx2 i2c_dev dwmac_intel dwmac_generic stmmac_platform stmmac ixgbe e1000 amd_xgbe mdio_devres mdio nls_utf8 pcs_xpcs ena nls_iso8859_1 nls_cp437 igb igc vfat fat button_hotplug(O) tg3 realtek phylink mii libphy
  [   48.673848] CR2: 0000000000000000

But it provides enough helper to get more information about the current
state of the system

::

  >>> trace = prog.crashed_thread().stack_trace()
  >>> trace
  #0  batadv_netlink_set_mesh (./build_dir/target-x86_64_musl/linux-x86_64/batman-adv-2024.3/net/batman-adv/netlink.c:447:17)
  #1  genl_family_rcv_msg_doit (net/netlink/genetlink.c:971:8)
  #2  genl_family_rcv_msg (net/netlink/genetlink.c:1051:10)
  #3  genl_rcv_msg (net/netlink/genetlink.c:1066:8)
  #4  netlink_rcv_skb (net/netlink/af_netlink.c:2537:9)
  #5  genl_rcv (net/netlink/genetlink.c:1075:2)
  #6  netlink_unicast_kernel (net/netlink/af_netlink.c:1323:3)
  #7  netlink_unicast (net/netlink/af_netlink.c:1349:10)
  #8  netlink_sendmsg (net/netlink/af_netlink.c:1891:8)
  #9  sock_sendmsg_nosec (net/socket.c:730:12)
  #10 __sock_sendmsg (net/socket.c:745:16)
  #11 ____sys_sendmsg (net/socket.c:2595:8)
  #12 ___sys_sendmsg (net/socket.c:2649:8)
  #13 __sys_sendmsg (net/socket.c:2678:8)
  #14 __do_sys_sendmsg (net/socket.c:2687:9)
  #15 __se_sys_sendmsg (net/socket.c:2685:1)
  #16 __x64_sys_sendmsg (net/socket.c:2685:1)
  #17 x64_sys_call (./arch/x86/include/generated/asm/syscalls_64.h:47:1)
  #18 do_syscall_x64 (arch/x86/entry/common.c:51:14)
  #19 do_syscall_64 (arch/x86/entry/common.c:81:7)
  #20 entry_SYSCALL_64+0xb0/0x1b3 (arch/x86/entry/entry_64.S:121)


  >>> trace[0]
  #0 at 0xffffffffa073efa2 (batadv_netlink_set_mesh+0x32/0x2ae) in batadv_netlink_set_mesh at ./build_dir/target-x86_64_musl/linux-x86_64/batman-adv-2024.3/net/batman-adv/netlink.c:447:17
  >>> trace[0]["attr"]
  (struct nlattr *)0x0

  >>> trace[0]["info"].attrs[prog.constant('BATADV_ATTR_AGGREGATED_OGMS_ENABLED')]
  *(struct nlattr *)0xffff88800458dd5c = {
          .nla_len = (__u16)5,
          .nla_type = (__u16)41,
  }
