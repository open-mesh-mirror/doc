.. SPDX-License-Identifier: GPL-2.0

OpenWrt KGDB
============

As shown in the :doc:`Kernel_debugging_with_qemu's_GDB_server` documentation, it
is easy to debug Linux kernel in an :doc:`emulated system <OpenWrt_in_QEMU>`.
But some problems might only be reproducible on actual hardware
:doc:`connected to the emulation setup <Mixing_VM_with_gluon_hardware>`. It
is therefore sometimes necessary to debug a whole system.

In best case, the system can be :doc:`debugged using
JTAG <Kernel_debugging_over_JTAG>`. But this
is often not possible and an in-kernel gdb remote stub like
`KGDB <https://www.kernel.org/doc/html/latest/dev-tools/kgdb.html>`__
has to be used. The only requirement it has on the actual board is a
simple serial console with poll_{get,put}_char() support.

Preparing OpenWrt
-----------------

Turning off watchdog
~~~~~~~~~~~~~~~~~~~~

Most CPUs have some kind of watchdog integrated. They can often be
turned off and are often inactive when the watchdog driver is not
loaded. For example, ath79/ar71xx can be build without the internal
watchdog support by changing in target/linux/{ar71xx,ath79}/config-\*:

.. code-block:: diff

  -CONFIG_ATH79_WDT=y
  +# CONFIG_ATH79_WDT is not set

Unfortunately, there are also external watchdog chips which cannot be
turned off. They have to be manually triggered regularly during the
debugging process to prevent a sudden reboot. The details depend on the
actual hardware but it often ends up in writing to a specific (GPIO
control/set/clear) register. An example how to manually trigger an GPIO
connected watchdog manually can be found in
:ref:`GDB Linux snippets <devtools-gdb-linux-snippets-Working-with-external-Watchdog-over-GPIO>`

Enabling KGDB in kernel
~~~~~~~~~~~~~~~~~~~~~~~

The actual kernel gdbstub cannot be enabled via OpenWrt's .config.
Instead the actual configuration has to be set in the target
configuration:

::

  # CONFIG_STRICT_KERNEL_RWX is not set
  CONFIG_FRAME_POINTER=y
  CONFIG_KGDB=y
  CONFIG_KGDB_SERIAL_CONSOLE=y
  CONFIG_DEBUG_INFO=y
  CONFIG_DEBUG_INFO_DWARF4=y
  # CONFIG_DEBUG_INFO_REDUCED is not set
  CONFIG_GDB_SCRIPTS=y

For x86-64, the change (mostly created using make kernel_menuconfig)
would be:

.. code-block:: diff

  diff --git a/target/linux/x86/config-4.14 b/target/linux/x86/config-4.14
  index 014e7b275b..c6c6f871a9 100644
  --- a/target/linux/x86/config-4.14
  +++ b/target/linux/x86/config-4.14
  @@ -70,6 +70,7 @@ CONFIG_CLONE_BACKWARDS=y
   CONFIG_COMMON_CLK=y
   CONFIG_COMPAT_32=y
   # CONFIG_COMPAT_VDSO is not set
  +CONFIG_CONSOLE_POLL=y
   CONFIG_CONSOLE_TRANSLATIONS=y
   # CONFIG_CPU5_WDT is not set
   CONFIG_CPU_FREQ=y
  @@ -108,6 +109,9 @@ CONFIG_DCACHE_WORD_ACCESS=y
   # CONFIG_DCDBAS is not set
   # CONFIG_DEBUG_BOOT_PARAMS is not set
   # CONFIG_DEBUG_ENTRY is not set
  +CONFIG_DEBUG_INFO=y
  +CONFIG_DEBUG_INFO_DWARF4=y
  +# CONFIG_DEBUG_INFO_REDUCED is not set
   CONFIG_DEBUG_MEMORY_INIT=y
   # CONFIG_DEBUG_NMI_SELFTEST is not set
   # CONFIG_DEBUG_TLBFLUSH is not set
  @@ -144,6 +148,7 @@ CONFIG_FUSION=y
   # CONFIG_FUSION_LOGGING is not set
   CONFIG_FUSION_MAX_SGE=128
   CONFIG_FUSION_SPI=y
  +CONFIG_GDB_SCRIPTS=y
   CONFIG_GENERIC_ALLOCATOR=y
   CONFIG_GENERIC_BUG=y
   CONFIG_GENERIC_CLOCKEVENTS=y
  @@ -288,6 +293,11 @@ CONFIG_KALLSYMS=y
   CONFIG_KEXEC=y
   CONFIG_KEXEC_CORE=y
   CONFIG_KEYBOARD_ATKBD=y
  +CONFIG_KGDB=y
  +# CONFIG_KGDB_KDB is not set
  +# CONFIG_KGDB_LOW_LEVEL_TRAP is not set
  +CONFIG_KGDB_SERIAL_CONSOLE=y
  +# CONFIG_KGDB_TESTS is not set
   # CONFIG_LEDS_CLEVO_MAIL is not set
   CONFIG_LIBNVDIMM=y
   # CONFIG_M486 is not set
  @@ -296,6 +306,7 @@ CONFIG_M586MMX=y
   # CONFIG_M586TSC is not set
   # CONFIG_M686 is not set
   # CONFIG_MACHZ_WDT is not set
  +CONFIG_MAGIC_SYSRQ=y
   # CONFIG_MATOM is not set
   # CONFIG_MCORE2 is not set
   # CONFIG_MCRUSOE is not set
  @@ -404,6 +415,7 @@ CONFIG_SCx200HR_TIMER=y
   # CONFIG_SCx200_WDT is not set
   # CONFIG_SERIAL_8250_FSL is not set
   CONFIG_SERIAL_8250_PCI=y
  +# CONFIG_SERIAL_KGDB_NMI is not set
   CONFIG_SERIO=y
   CONFIG_SERIO_I8042=y
   CONFIG_SERIO_LIBPS2=y
  diff --git a/target/linux/x86/image/Makefile b/target/linux/x86/image/Makefile
  index 84a3d88a7f..c8a017f970 100644
  --- a/target/linux/x86/image/Makefile
  +++ b/target/linux/x86/image/Makefile
  @@ -14,7 +14,7 @@ GRUB2_MODULES_ISO = biosdisk boot chain configfile iso9660 linux ls part_msdos r
   GRUB_TERMINALS =
   GRUB_SERIAL_CONFIG =
   GRUB_TERMINAL_CONFIG =
  -GRUB_CONSOLE_CMDLINE =
  +GRUB_CONSOLE_CMDLINE = nokaslr

   USE_ATKBD = generic 64

For ar71xx (GL.inet AR750 in my case), it would look like:

.. code-block:: diff

  diff --git a/target/linux/ar71xx/config-4.14 b/target/linux/ar71xx/config-4.14
  index 9a524fae4316caa10431bd6b3b4dadbe8660f14c..397e15bcecd4e9c696a2321174969541b673cbd3 100644
  --- a/target/linux/ar71xx/config-4.14
  +++ b/target/linux/ar71xx/config-4.14
  @@ -282,7 +282,7 @@ CONFIG_ATH79=y
   # CONFIG_ATH79_NVRAM is not set
   # CONFIG_ATH79_PCI_ATH9K_FIXUP is not set
   # CONFIG_ATH79_ROUTERBOOT is not set
  -CONFIG_ATH79_WDT=y
  +# CONFIG_ATH79_WDT is not set
   CONFIG_CEVT_R4K=y
   CONFIG_CLKDEV_LOOKUP=y
   CONFIG_CLONE_BACKWARDS=y
  @@ -291,6 +291,8 @@ CONFIG_CMDLINE_BOOL=y
   # CONFIG_CMDLINE_OVERRIDE is not set
   # CONFIG_COMMON_CLK_BOSTON is not set
   CONFIG_COMMON_CLK=y
  +CONFIG_CONSOLE_POLL=y
  +CONFIG_CONSOLE_TRANSLATIONS=y
   CONFIG_CPU_BIG_ENDIAN=y
   CONFIG_CPU_GENERIC_DUMP_TLB=y
   CONFIG_CPU_HAS_PREFETCH=y
  @@ -308,10 +310,15 @@ CONFIG_CPU_SUPPORTS_MSA=y
   CONFIG_CRYPTO_RNG2=y
   CONFIG_CRYPTO_WORKQUEUE=y
   CONFIG_CSRC_R4K=y
  +CONFIG_DEBUG_INFO=y
  +CONFIG_DEBUG_INFO_DWARF4=y
  +# CONFIG_DEBUG_INFO_REDUCED is not set
   CONFIG_DMA_NONCOHERENT=y
  +CONFIG_DUMMY_CONSOLE=y
   CONFIG_EARLY_PRINTK=y
   CONFIG_ETHERNET_PACKET_MANGLE=y
   CONFIG_FIXED_PHY=y
  +CONFIG_GDB_SCRIPTS=y
   CONFIG_GENERIC_ATOMIC64=y
   CONFIG_GENERIC_CLOCKEVENTS=y
   CONFIG_GENERIC_CMOS_UPDATE=y
  @@ -372,6 +379,7 @@ CONFIG_HAVE_PERF_EVENTS=y
   CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
   CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
   CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
  +CONFIG_HW_CONSOLE=y
   CONFIG_HZ_PERIODIC=y
   CONFIG_I2C=y
   CONFIG_I2C_ALGOBIT=y
  @@ -381,13 +389,20 @@ CONFIG_IMAGE_CMDLINE_HACK=y
   CONFIG_INITRAMFS_ROOT_GID=0
   CONFIG_INITRAMFS_ROOT_UID=0
   CONFIG_INITRAMFS_SOURCE="../../root"
  +CONFIG_INPUT=y
   CONFIG_INTEL_XWAY_PHY=y
   CONFIG_IP17XX_PHY=y
   CONFIG_IRQ_DOMAIN=y
   CONFIG_IRQ_FORCED_THREADING=y
   CONFIG_IRQ_MIPS_CPU=y
   CONFIG_IRQ_WORK=y
  +CONFIG_KGDB=y
  +# CONFIG_KGDB_KDB is not set
  +# CONFIG_KGDB_LOW_LEVEL_TRAP is not set
  +CONFIG_KGDB_SERIAL_CONSOLE=y
  +# CONFIG_KGDB_TESTS is not set
   CONFIG_LEDS_GPIO=y
  +CONFIG_MAGIC_SYSRQ=y
   CONFIG_MARVELL_PHY=y
   CONFIG_MDIO_BITBANG=y
  + CONFIG_MDIO_BOARDINFO=y
  +@@ -454,6 +469,7 @@ CONFIG_RTL8367_PHY=y
   # CONFIG_SERIAL_8250_FSL is not set
   CONFIG_SERIAL_8250_NR_UARTS=1
   CONFIG_SERIAL_8250_RUNTIME_UARTS=1
  +# CONFIG_SERIAL_KGDB_NMI is not set
   # CONFIG_SOC_AR71XX is not set
   # CONFIG_SOC_AR724X is not set
   # CONFIG_SOC_AR913X is not set
  +@@ -484,3 +500,8 @@ CONFIG_SYS_SUPPORTS_ZBOOT=y
  + CONFIG_SYS_SUPPORTS_ZBOOT_UART_PROM=y
   CONFIG_TICK_CPU_ACCOUNTING=y
   CONFIG_USB_SUPPORT=y
  +# CONFIG_VGACON_SOFT_SCROLLBACK is not set
  +CONFIG_VGA_CONSOLE=y
  +CONFIG_VT=y
  +CONFIG_VT_CONSOLE=y
  +# CONFIG_VT_HW_CONSOLE_BINDING is not set
  diff --git a/target/linux/ar71xx/image/Makefile b/target/linux/ar71xx/image/Makefile
  index 804532b55cb145134acf47accd095bbb24dee059..c485389f56c34ca8216c1016d515be2836ab2349 100644
  --- a/target/linux/ar71xx/image/Makefile
  +++ b/target/linux/ar71xx/image/Makefile
  @@ -58,7 +58,7 @@ define Device/Default
     PROFILES = Default Minimal $$(DEVICE_PROFILE)
     MTDPARTS :=
     BLOCKSIZE := 64k
  -  CONSOLE := ttyS0,115200
  +  CONSOLE := ttyS0,115200 nokaslr
     CMDLINE = $$(if $$(BOARDNAME),board=$$(BOARDNAME)) $$(if $$(MTDPARTS),mtdparts=$$(MTDPARTS)) $$(if $$(CONSOLE),console=$$(CONSOLE))
     KERNEL := kernel-bin | patch-cmdline | lzma | uImage lzma
     COMPILE :=

Enabling python support for gdb
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OpenWrt will build a gdb when ``CONFIG_GDB=y`` is set in .config. But this
version is missing python support. But it can be enabled with following
patch:

.. code-block:: diff

  diff --git a/toolchain/gdb/Makefile b/toolchain/gdb/Makefile
  index 41ba9853fd26d5ea2ba3759946a9591c668d92e9..afe4f01201fca21adc465a3fbd3c3751ec23df25 100644
  --- a/toolchain/gdb/Makefile
  +++ b/toolchain/gdb/Makefile
  @@ -45,7 +45,7 @@ HOST_CONFIGURE_ARGS = \
      --without-included-gettext \
      --enable-threads \
      --with-expat \
  -   --without-python \
  +   --with-python \
      --disable-binutils \
      --disable-ld \
      --disable-gas \
  @@ -56,9 +56,11 @@ define Host/Install
      $(INSTALL_BIN) $(HOST_BUILD_DIR)/gdb/gdb $(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)gdb
      ln -fs $(TARGET_CROSS)gdb $(TOOLCHAIN_DIR)/bin/$(GNU_TARGET_NAME)-gdb
      strip $(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)gdb
  +	-$(MAKE) -C $(HOST_BUILD_DIR)/gdb/data-directory install
   endef

   define Host/Clean
  +   -$(MAKE) -C $(HOST_BUILD_DIR)/gdb/data-directory uninstall
      rm -rf \
          $(HOST_BUILD_DIR) \
          $(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)gdb \

Start debugging session
-----------------------

Turning off kASLR
~~~~~~~~~~~~~~~~~

The kernel address space layout randomization complicates the resolving
of addresses of symbols. It is highly recommended to start the kernel
with the parameter "nokaslr". For example by adding it to CONFIG_CMDLINE
or by adjusting the bootargs in the bootloader. It should be checked in
/proc/cmdline whether it was really booted with this parameter.

Configure KGDB serial
~~~~~~~~~~~~~~~~~~~~~

The kgdb needs a serial device to work. This has to be set in the module
parameter. We assume now that the serial console on our device is ttyS0
with baudrate 115200:

.. code-block:: sh

  echo ttyS0,115200 > /sys/module/kgdboc/parameters/kgdboc

Switch to kgdb
~~~~~~~~~~~~~~

The gdb frontend cannot directly talk to the kernel over serial and
create breakpoints. The sysrq mechanism has to be used to switch from
Linux to kgdb before gdb can be used. Under OpenWrt, this can be done
using

.. code-block:: sh

  echo g > /proc/sysrq-trigger

Connecting gdb
~~~~~~~~~~~~~~

I would use following folder in my x86-64 build environment but they
will be different for other architectures or OpenWrt versions:

* ``LINUX_DIR=${OPENWRT_DIR}/build_dir/target-x86_64_musl/linux-x86_64/linux-4.14.148/``
* ``GDB=${OPENWRT_DIR}/staging_dir/toolchain-x86_64_gcc-7.4.0_musl/bin/x86_64-openwrt-linux-gdb``
* ``BATADV_DIR=${OPENWRT_DIR}/build_dir/target-x86_64_musl/linux-x86_64/batman-adv-2019.2/``

When kgdb is activated using sysrq, we can configure gdb. It has to
connect via a serial adapter to the target device. We must change to the
LINUX_DIR first and can then start our target specific GDB with our
uncompressed kernel image before we will connect to the remote device.

.. code-block:: sh

  cd "${LINUX_DIR}"
  "${GDB}" -iex "set auto-load safe-path scripts/gdb/" -iex "set serial baud 115200" -iex "target remote /dev/ttyUSB0" ./vmlinux

In this example, we are using an USB TTL converter (/dev/ttyUSB0). It
has to be configured in gdb

::

  lx-symbols ..

  continue

You should make sure that it doesn't load any \ **.ko files from
ipkg-**\  directories. These files are stripped and doesn't contain the
necessary symbol information. When necessary, just delete these folders
or specify the folders with the unstripped kernel modules:

::

  lx-symbols ../batman-adv-2019.2/.pkgdir/ ../backports-4.19.66-1/.pkgdir/ ../button-hotplug/.pkgdir/

The rest of the process works similar to debugging using gdbserver. Just
set some additional breakpoints and let the kernel run again. kgdb will
then inform gdb whenever a breakpoints was hit. Just keep in mind that
it is not possible to interrupt the kernel from gdb (without a Oops or
an already existing breakpoint) - use the sysrq mechanism again from
Linux to switch back to kgdb.

Some other ideas are documented in
:doc:`GDB_Linux_snippets`.

The kernel hacking debian image page should also be checked to
:ref:`increase the chance of getting debugable modules <devtools-hacking-debian-image-building-the-batman-adv-module>` which didn't had all
information optimized away. The relevant flags could be set directly in
the routing feed like this:

.. code-block:: diff

  diff --git a/batman-adv/Makefile b/batman-adv/Makefile
  index a7c6a79..c18f978 100644
  --- a/batman-adv/Makefile
  +++ b/batman-adv/Makefile
  @@ -89,7 +89,7 @@ define Build/Compile
          CROSS_COMPILE="$(TARGET_CROSS)" \
          SUBDIRS="$(PKG_BUILD_DIR)/net/batman-adv" \
          $(PKG_EXTRA_KCONFIG) \
  -       EXTRA_CFLAGS="$(PKG_EXTRA_CFLAGS)" \
  +       EXTRA_CFLAGS="$(PKG_EXTRA_CFLAGS) -fno-inline -Og -fno-optimize-sibling-calls" \
          NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
          modules
   endef
