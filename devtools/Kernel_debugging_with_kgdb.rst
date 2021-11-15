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
loaded. For example, ath79 can be build without the internal watchdog
support by changing in ``target/linux/ath79/config-*``:

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
  
  # optional: to allow activation of kgdb over serial by agent-proxy
  # instead of manually triggering it over /proc/sysrq-trigger
  CONFIG_MAGIC_SYSRQ_SERIAL=y

For x86-64, the change (mostly created using make kernel_menuconfig)
would be:

.. code-block:: diff

  diff --git a/target/linux/x86/config-5.4 b/target/linux/x86/config-5.4
  index 6676f9501a..2518c8f57b 100644
  --- a/target/linux/x86/config-5.4
  +++ b/target/linux/x86/config-5.4
  @@ -78,6 +78,7 @@ CONFIG_COMMON_CLK=y
   CONFIG_COMPAT_32=y
   CONFIG_COMPAT_32BIT_TIME=y
   # CONFIG_COMPAT_VDSO is not set
  +CONFIG_CONSOLE_POLL=y
   CONFIG_CONSOLE_TRANSLATIONS=y
   # CONFIG_CPU5_WDT is not set
   CONFIG_CPU_FREQ=y
  @@ -116,6 +117,9 @@ CONFIG_DCACHE_WORD_ACCESS=y
   # CONFIG_DCDBAS is not set
   # CONFIG_DEBUG_BOOT_PARAMS is not set
   # CONFIG_DEBUG_ENTRY is not set
  +CONFIG_DEBUG_INFO=y
  +CONFIG_DEBUG_INFO_DWARF4=y
  +# CONFIG_DEBUG_INFO_REDUCED is not set
   CONFIG_DEBUG_MEMORY_INIT=y
   CONFIG_DEBUG_MISC=y
   # CONFIG_DEBUG_NMI_SELFTEST is not set
  @@ -161,6 +165,7 @@ CONFIG_FUSION=y
   CONFIG_FUSION_MAX_SGE=128
   CONFIG_FUSION_SPI=y
   CONFIG_FW_LOADER_PAGED_BUF=y
  +CONFIG_GDB_SCRIPTS=y
   CONFIG_GENERIC_ALLOCATOR=y
   CONFIG_GENERIC_BUG=y
   CONFIG_GENERIC_CLOCKEVENTS=y
  @@ -306,6 +311,11 @@ CONFIG_KALLSYMS=y
   CONFIG_KEXEC=y
   CONFIG_KEXEC_CORE=y
   CONFIG_KEYBOARD_ATKBD=y
  +CONFIG_KGDB=y
  +# CONFIG_KGDB_KDB is not set
  +# CONFIG_KGDB_LOW_LEVEL_TRAP is not set
  +CONFIG_KGDB_SERIAL_CONSOLE=y
  +# CONFIG_KGDB_TESTS is not set
   # CONFIG_LEDS_CLEVO_MAIL is not set
   CONFIG_LOCK_DEBUGGING_SUPPORT=y
   # CONFIG_M486 is not set
  @@ -314,6 +324,8 @@ CONFIG_M586MMX=y
   # CONFIG_M586TSC is not set
   # CONFIG_M686 is not set
   # CONFIG_MACHZ_WDT is not set
  +CONFIG_MAGIC_SYSRQ=y
  +CONFIG_MAGIC_SYSRQ_SERIAL=y
   # CONFIG_MATOM is not set
   # CONFIG_MCORE2 is not set
   # CONFIG_MCRUSOE is not set
  @@ -421,6 +433,7 @@ CONFIG_SCx200HR_TIMER=y
   # CONFIG_SCx200_GPIO is not set
   # CONFIG_SCx200_WDT is not set
   CONFIG_SERIAL_8250_PCI=y
  +# CONFIG_SERIAL_KGDB_NMI is not set
   CONFIG_SERIO=y
   CONFIG_SERIO_I8042=y
   CONFIG_SERIO_LIBPS2=y
  diff --git a/target/linux/x86/image/Makefile b/target/linux/x86/image/Makefile
  index f61e4ff802..e8c05c58e5 100644
  --- a/target/linux/x86/image/Makefile
  +++ b/target/linux/x86/image/Makefile
  @@ -9,7 +9,7 @@ GRUB2_VARIANT =
   GRUB_TERMINALS =
   GRUB_SERIAL_CONFIG =
   GRUB_TERMINAL_CONFIG =
  -GRUB_CONSOLE_CMDLINE =
  +GRUB_CONSOLE_CMDLINE = nokaslr
   
   ifneq ($(CONFIG_GRUB_CONSOLE),)
     GRUB_CONSOLE_CMDLINE += console=tty0

For ath79 (GL.inet AR750 in my case), it would look like:

.. code-block:: diff

  diff --git a/target/linux/ath79/config-5.4 b/target/linux/ath79/config-5.4
  index 60f57692e2..01b66897fe 100644
  --- a/target/linux/ath79/config-5.4
  +++ b/target/linux/ath79/config-5.4
  @@ -25,7 +25,7 @@ CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT=y
   CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
   CONFIG_AT803X_PHY=y
   CONFIG_ATH79=y
  -CONFIG_ATH79_WDT=y
  +# CONFIG_ATH79_WDT is not set
   CONFIG_BLK_MQ_PCI=y
   CONFIG_CEVT_R4K=y
   CONFIG_CLKDEV_LOOKUP=y
  @@ -34,6 +34,8 @@ CONFIG_CMDLINE="rootfstype=squashfs,jffs2"
   CONFIG_CMDLINE_BOOL=y
   # CONFIG_CMDLINE_OVERRIDE is not set
   CONFIG_COMMON_CLK=y
  +CONFIG_CONSOLE_POLL=y
  +CONFIG_CONSOLE_TRANSLATIONS=y
   # CONFIG_COMMON_CLK_BOSTON is not set
   CONFIG_COMPAT_32BIT_TIME=y
   CONFIG_CPU_BIG_ENDIAN=y
  @@ -52,9 +54,13 @@ CONFIG_CPU_SUPPORTS_HIGHMEM=y
   CONFIG_CPU_SUPPORTS_MSA=y
   CONFIG_CRYPTO_RNG2=y
   CONFIG_CSRC_R4K=y
  +CONFIG_DEBUG_INFO=y
  +CONFIG_DEBUG_INFO_DWARF4=y
  +# CONFIG_DEBUG_INFO_REDUCED is not set
   CONFIG_DMA_NONCOHERENT=y
   CONFIG_DMA_NONCOHERENT_CACHE_SYNC=y
   CONFIG_DTC=y
  +CONFIG_DUMMY_CONSOLE=y
   CONFIG_EARLY_PRINTK=y
   CONFIG_EFI_EARLYCON=y
   CONFIG_ETHERNET_PACKET_MANGLE=y
  @@ -63,6 +69,7 @@ CONFIG_FONT_8x16=y
   CONFIG_FONT_AUTOSELECT=y
   CONFIG_FONT_SUPPORT=y
   CONFIG_FW_LOADER_PAGED_BUF=y
  +CONFIG_GDB_SCRIPTS=y
   CONFIG_GENERIC_ATOMIC64=y
   CONFIG_GENERIC_CLOCKEVENTS=y
   CONFIG_GENERIC_CMOS_UPDATE=y
  @@ -132,18 +139,27 @@ CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
   CONFIG_HAVE_RSEQ=y
   CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
   CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
  +CONFIG_HW_CONSOLE=y
   CONFIG_HZ_PERIODIC=y
   CONFIG_IMAGE_CMDLINE_HACK=y
   CONFIG_INITRAMFS_SOURCE=""
  +CONFIG_INPUT=y
   CONFIG_IRQCHIP=y
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
   # CONFIG_LEDS_RESET is not set
   CONFIG_LIBFDT=y
   CONFIG_LOCK_DEBUGGING_SUPPORT=y
  +CONFIG_MAGIC_SYSRQ=y
  +CONFIG_MAGIC_SYSRQ_SERIAL=y
   CONFIG_MDIO_BITBANG=y
   CONFIG_MDIO_BUS=y
   CONFIG_MDIO_DEVICE=y
  @@ -161,6 +177,7 @@ CONFIG_MIPS_CLOCK_VSYSCALL=y
   # CONFIG_MIPS_CMDLINE_FROM_BOOTLOADER is not set
   CONFIG_MIPS_CMDLINE_FROM_DTB=y
   # CONFIG_MIPS_ELF_APPENDED_DTB is not set
  +CONFIG_MIPS_FP_SUPPORT=y
   CONFIG_MIPS_L1_CACHE_SHIFT=5
   # CONFIG_MIPS_NO_APPENDED_DTB is not set
   CONFIG_MIPS_RAW_APPENDED_DTB=y
  @@ -217,6 +234,7 @@ CONFIG_RESET_ATH79=y
   CONFIG_RESET_CONTROLLER=y
   CONFIG_SERIAL_8250_NR_UARTS=1
   CONFIG_SERIAL_8250_RUNTIME_UARTS=1
  +# CONFIG_SERIAL_KGDB_NMI is not set
   CONFIG_SERIAL_AR933X=y
   CONFIG_SERIAL_AR933X_CONSOLE=y
   CONFIG_SERIAL_AR933X_NR_UARTS=2
  @@ -248,3 +266,8 @@ CONFIG_TICK_CPU_ACCOUNTING=y
   CONFIG_TINY_SRCU=y
   CONFIG_USB_SUPPORT=y
   CONFIG_USE_OF=y
  +# CONFIG_VGACON_SOFT_SCROLLBACK is not set
  +# CONFIG_VGA_CONSOLE is not set
  +CONFIG_VT=y
  +# CONFIG_VT_CONSOLE is not set
  +# CONFIG_VT_HW_CONSOLE_BINDING is not set

Enabling python support for gdb
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OpenWrt will build a gdb when ``CONFIG_GDB=y`` is set in .config. But it is
important to also enable the python support via ``CONFIG_GDB_PYTHON=y`` or
otherwise the Linux helper will not be able to correctly scan for modules.
This feature was only added **after** the OpenWrt 21.02 release.

For older versions of OpenWrt (including 21.02.x), following script can also be
used:

.. code-block:: diff

  diff --git a/toolchain/gdb/Makefile b/toolchain/gdb/Makefile
  index 05e3c7de3c..0ab20cb2d5 100644
  --- a/toolchain/gdb/Makefile
  +++ b/toolchain/gdb/Makefile
  @@ -36,7 +36,7 @@ HOST_CONFIGURE_ARGS = \
   	--without-included-gettext \
   	--enable-threads \
   	--with-expat \
  -	--without-python \
  +	--with-python \
   	--disable-unit-tests \
   	--disable-ubsan \
   	--disable-binutils \
  @@ -49,9 +49,11 @@ define Host/Install
   	$(INSTALL_BIN) $(HOST_BUILD_DIR)/gdb/gdb $(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)gdb
   	ln -fs $(TARGET_CROSS)gdb $(TOOLCHAIN_DIR)/bin/$(GNU_TARGET_NAME)-gdb
   	strip $(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)gdb
  +	-$(MAKE) -C $(HOST_BUILD_DIR)/gdb/data-directory install
   endef
   
   define Host/Clean
  +	-$(MAKE) -C $(HOST_BUILD_DIR)/gdb/data-directory uninstall
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

* ``LINUX_DIR=${OPENWRT_DIR}/build_dir/target-x86_64_musl/linux-x86_64/linux-5.4.143/``
* ``GDB=${OPENWRT_DIR}/staging_dir/toolchain-x86_64_gcc-8.4.0_musl/bin/x86_64-openwrt-linux-gdb``
* ``BATADV_DIR=${OPENWRT_DIR}/build_dir/target-x86_64_musl/linux-x86_64/batman-adv-2021.1/``

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

  lx-symbols ../batman-adv-2021.1/.pkgdir/ ../backports-5.10.42-1/.pkgdir/ ../button-hotplug/.pkgdir/

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
  index 967965e..0abd42f 100644
  --- a/batman-adv/Makefile
  +++ b/batman-adv/Makefile
  @@ -17,6 +17,9 @@ PKG_LICENSE_FILES:=LICENSES/preferred/GPL-2.0 LICENSES/preferred/MIT
   
   STAMP_CONFIGURED_DEPENDS := $(STAGING_DIR)/usr/include/mac80211-backport/backport/autoconf.h
   
  +RSTRIP:=:
  +STRIP:=:
  +
   include $(INCLUDE_DIR)/kernel.mk
   include $(INCLUDE_DIR)/package.mk
   
  @@ -77,7 +80,7 @@ define Build/Compile
   		$(KERNEL_MAKE_FLAGS) \
   		M="$(PKG_BUILD_DIR)/net/batman-adv" \
   		$(PKG_EXTRA_KCONFIG) \
  -		EXTRA_CFLAGS="$(PKG_EXTRA_CFLAGS)" \
  +		EXTRA_CFLAGS="$(PKG_EXTRA_CFLAGS) -fno-inline -Og -fno-optimize-sibling-calls" \
   		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
   		modules
   endef

Agent-Proxy
-----------

Instead of switching all the time between gdb and the terminal emulator
(via UART/TTL), it can be rather helpful to use a splitter which can multiplex
the kgdb and the normal terminal. So instead of using screen/minicom/... + gdb
against the tty device, the different sessions are just started against a TCP
port.

Installation
~~~~~~~~~~~~

.. code-block:: shell

  $ git clone https://git.kernel.org/pub/scm/utils/kernel/kgdb/agent-proxy.git/
  $ make -C agent-proxy

Starting up session
~~~~~~~~~~~~~~~~~~~

.. code-block:: shell

  $ /agent-proxy/agent-proxy '127.0.0.1:5550^127.0.0.1:5551' 0 /dev/ttyUSB0,115200

To connect to the terminal session, a simple telnet or telnet-like tool
is enough:

.. code-block:: shell

  $ screen //telnet localhost 5550

The setup of the kgdboc must happen exactly as described before. Including the
switch to the debugging mode via sysrq.

The gdb has to be attached like to a remote gdb session

.. code-block:: shell

  $ cd "${LINUX_DIR}"
  $ "${GDB}" -iex "set auto-load safe-path scripts/gdb/" -iex "target remote localhost:5551" ./vmlinux

Enable KGDB on panic
--------------------

Usually, a debugger catches problems like segfaults and allows a user to debug
the problem further. On modern setups with kgdb, this is not the case because
the system will automatically reboot after n-seconds.

This can be avoided by changing the sysctl config ``kernel.panic`` to 0. Either
in ``/etc/sysctl.d/`` or by manually issuing

.. code-block:: shell

  sysctl -w kernel.panic=0

If a kgdb(oc) is attached then it should automatically receive a message when
the Oops was noticed and can then be debugged further.
