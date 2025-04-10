.. SPDX-License-Identifier: GPL-2.0

OpenWrt KGDB
============

As shown in the :doc:`Kernel_debugging_with_qemu's_GDB_server`
documentation, it is easy to debug the Linux kernel in an
:doc:`emulated system <OpenWrt_in_QEMU>`. But some problems might only be
reproducible on actual hardware
(:doc:`connected to the emulation setup <Mixing_VM_with_gluon_hardware>`). It
is therefore sometimes necessary to debug a whole system.

In best case, the system can be :doc:`debugged using
JTAG <Kernel_debugging_over_JTAG>`. But this is often not possible and an in-kernel gdb remote
stub like
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

It is also possible to stop the watchdog service at runtime without
disabling the driver. This should work for many optional watchdogs in
SoCs:

.. code-block:: sh

  ubus call system watchdog '{"magicclose":true}'
  ubus call system watchdog '{"stop":true}'

Enabling KGDB in kernel
~~~~~~~~~~~~~~~~~~~~~~~

OpenWrt must be modified slightly to expose the kernel gdbstub
(``CONFIG_KERNEL_KGDB``):

.. code-block:: diff

  From: Sven Eckelmann <sven@narfation.org>
  Date: Thu, 13 Oct 2022 16:40:21 +0200
  Subject: openwrt: Add support for easily selectable kernel debugger support

  When enabling this KERNEL_KGDB (after disabling KERNEL_DEBUG_INFO_REDUCED),
  make sure to clean some packages to make sure that they are compiled with
  the correct settings:

      make toolchain/gdb/clean
      make toolchain/gdb/compile -j$(nproc || echo 1)
      make target/linux/clean
      make -j$(nproc || echo 1)

  The serial console will be shared between normal serial output and (k)gdb,
  it is necessary to have an agent installed on your host system which
  extracts the part relevant for (k)gdb.

      git clone https://git.kernel.org/pub/scm/utils/kernel/kgdb/agent-proxy.git/
      make -C agent-proxy
      ./agent-proxy/agent-proxy '127.0.0.1:5550^127.0.0.1:5551' 0 /dev/ttyUSB1,115200

  It is then possible to see the full serial output in screen via:

      screen //telnet localhost 5550

  On the target system, it is necessary to prepare the debugging session:

      echo ttyS0,115200 > /sys/module/kgdboc/parameters/kgdboc
      ubus call system watchdog '{"magicclose":true}'
      ubus call system watchdog '{"stop":true}'

  Sometimes it might be necessary to force Linux to switch to kgdb:

      echo g > /proc/sysrq-trigger

  The host can then connect to the kgdb using:

      cd "{LINUX_DIR}"
      cp ../vmlinux.debug vmlinux
      "${GDB}" -iex "set auto-load safe-path `pwd`/scripts/gdb/" -iex "target remote localhost:5551" vmlinux
      (gdb) lx-symbols ..
      (gdb) continue

  Signed-off-by: Sven Eckelmann <sven@narfation.org>

  diff --git a/config/Config-kernel.in b/config/Config-kernel.in
  --- a/config/Config-kernel.in
  +++ b/config/Config-kernel.in
  @@ -2,6 +2,50 @@
   #
   # Copyright (C) 2006-2014 OpenWrt.org

  +config KERNEL_VT
  +    bool
  +
  +config KERNEL_GDB_SCRIPTS
  +    select GDB_PYTHON
  +    bool
  +
  +config KERNEL_HW_CONSOLE
  +    bool
  +
  +config KERNEL_CONSOLE_POLL
  +    bool
  +
  +config KERNEL_MAGIC_SYSRQ
  +    bool
  +
  +config KERNEL_MAGIC_SYSRQ_SERIAL
  +    bool
  +
  +config KERNEL_KGDB_SERIAL_CONSOLE
  +    bool
  +
  +config KERNEL_KGDB_HONOUR_BLOCKLIST
  +    bool
  +
  +config KERNEL_MIPS_FP_SUPPORT
  +    depends on (mips || mipsel || mips64 || mips64el)
  +    bool
  +
  +config KERNEL_KGDB
  +    select KERNEL_VT
  +    select KERNEL_GDB_SCRIPTS
  +    select KERNEL_HW_CONSOLE
  +    select KERNEL_CONSOLE_POLL
  +    select KERNEL_MAGIC_SYSRQ
  +    select KERNEL_MAGIC_SYSRQ_SERIAL
  +    select KERNEL_KGDB_SERIAL_CONSOLE
  +    select KERNEL_KGDB_HONOUR_BLOCKLIST
  +    select KERNEL_MIPS_FP_SUPPORT if (mips || mipsel || mips64 || mips64el)
  +    
  +    depends on KERNEL_DEBUG_INFO && !KERNEL_DEBUG_INFO_REDUCED
  +    bool "Enable kernel debugger over serial"
  +
  +
   config KERNEL_BUILD_USER
      string "Custom Kernel Build User Name"
      default "builder" if BUILDBOT
  @@ -471,7 +515,7 @@ config KERNEL_MODULE_ALLOW_BTF_MISMATCH

   config KERNEL_DEBUG_INFO_REDUCED
      bool "Reduce debugging information"
  -   default y
  +   default n
      depends on KERNEL_DEBUG_INFO
      help
        If you say Y here gcc is instructed to generate less debugging
  diff --git a/include/kernel-build.mk b/include/kernel-build.mk
  --- a/include/kernel-build.mk
  +++ b/include/kernel-build.mk
  @@ -143,6 +143,7 @@ define BuildKernel
     $(LINUX_DIR)/.image: $(STAMP_CONFIGURED) $(if $(CONFIG_STRIP_KERNEL_EXPORTS),$(KERNEL_BUILD_DIR)/symtab.h) FORCE
      $(Kernel/CompileImage)
      $(Kernel/CollectDebug)
  +   +[ -z "$(CONFIG_KERNEL_GDB_SCRIPTS)" ] || $(KERNEL_MAKE) scripts_gdb
      touch $$@

     mostlyclean: FORCE
  diff --git a/target/linux/generic/config-6.6 b/target/linux/generic/config-6.6
  --- a/target/linux/generic/config-6.6
  +++ b/target/linux/generic/config-6.6
  @@ -7552,3 +7552,13 @@ CONFIG_ZONE_DMA=y
   # CONFIG_ZSMALLOC is not set
   CONFIG_ZSMALLOC_CHAIN_SIZE=8
   # CONFIG_ZSWAP is not set
  +
  +
  +# KGDB specific "disabled" options
  +# CONFIG_CONSOLE_TRANSLATIONS is not set
  +# CONFIG_VT_CONSOLE is not set
  +# CONFIG_VT_HW_CONSOLE_BINDING is not set
  +# CONFIG_SERIAL_KGDB_NMI is not set
  +# CONFIG_KGDB_TESTS is not set
  +# CONFIG_KGDB_KDB is not set
  +# CONFIG_KGDB_LOW_LEVEL_TRAP is not set

Start debugging session
-----------------------

Turning off kASLR
~~~~~~~~~~~~~~~~~

The kernel address space layout randomization complicates the resolving
of addresses of symbols. It is highly recommended to start the kernel
with the parameter "nokaslr". For example by adding it to ``CONFIG_CMDLINE``
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

-  LINUX_DIR=${OPENWRT_DIR}/build_dir/target-x86_64_musl/linux-x86_64/linux-6.6.73/
-  GDB=${OPENWRT_DIR}/staging_dir/toolchain-x86_64_gcc-13.3.0_musl/bin/x86_64-openwrt-linux-gdb
-  BATADV_DIR=${OPENWRT_DIR}/build_dir/target-x86_64_musl/linux-x86_64/batman-adv-2024.3/

When kgdb is activated using sysrq, we can configure gdb. It has to
connect via a serial adapter to the target device. We must change to the
LINUX_DIR first and can then start our target specific GDB with our
uncompressed kernel image before we will connect to the remote device.

.. code-block:: sh

  cd "${LINUX_DIR}"
  cp ../vmlinux.debug vmlinux
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

  lx-symbols ../batman-adv-2024.3/.pkgdir/ ../mac80211-regular/backports-6.12.6/.pkgdir/ ../button-hotplug/.pkgdir/

The rest of the process works similar to debugging using gdbserver. Just
set some additional breakpoints and let the kernel run again. kgdb will
then inform gdb whenever a breakpoints was hit. Just keep in mind that
it is not possible to interrupt the kernel from gdb (without a Oops or
an already existing breakpoint) - use the sysrq mechanism again from
Linux to switch back to kgdb.

Some other ideas are documented in [[GDB Linux_snippets]].

The kernel hacking debian image page should also be checked to
[[Kernel_hacking_Debian_image#Building-the-batman-adv-module|increase
the chance of getting debugable modules]] which didn't had all
information optimized away. The relevant flags could be set directly in
the routing feed like this:

.. code-block:: diff

  diff --git a/batman-adv/Makefile b/batman-adv/Makefile
  --- a/batman-adv/Makefile
  +++ b/batman-adv/Makefile
  @@ -28,6 +28,9 @@ PKG_CONFIG_DEPENDS += \
      CONFIG_BATMAN_ADV_DEBUG \
      CONFIG_BATMAN_ADV_TRACING

  +RSTRIP:=:
  +STRIP:=:
  +
   include $(INCLUDE_DIR)/kernel.mk
   include $(INCLUDE_DIR)/package.mk

  @@ -89,7 +92,7 @@ define Build/Compile
          $(KERNEL_MAKE_FLAGS) \
          M="$(PKG_BUILD_DIR)/net/batman-adv" \
          $(PKG_EXTRA_KCONFIG) \
  -       EXTRA_CFLAGS="$(PKG_EXTRA_CFLAGS)" \
  +       EXTRA_CFLAGS="$(PKG_EXTRA_CFLAGS) -fno-inline -Og -fno-optimize-sibling-calls -fno-reorder-blocks -fno-ipa-cp-clone -fno-partial-inlining" \
          NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
          modules
   endef

Agent-Proxy
-----------

Instead of switching all the time between gdb and the terminal emulator
(via UART/TTL), it can be rather helpful to use a splitter which can
multiplex the kgdb and the normal terminal. So, instead of using
screen/minicom/... + gdb against the tty device, the different sessions
are just started against a TCP port.

Installation
~~~~~~~~~~~~

.. code-block:: sh

  $ git clone https://git.kernel.org/pub/scm/utils/kernel/kgdb/agent-proxy.git/
  $ make -C agent-proxy

Starting up session
~~~~~~~~~~~~~~~~~~~

.. code-block:: sh

  $ ./agent-proxy/agent-proxy '127.0.0.1:5550^127.0.0.1:5551' 0 /dev/ttyUSB0,115200

To connect to the terminal session, a simple telnet or telnet-like tool
is enough:

.. code-block:: sh

  $ screen //telnet localhost 5550

The setup of the kgdboc must happen exactly as described before.
Including the switch to the debugging mode via sysrq.

The gdb has to be attached like to a remote gdb session

.. code-block:: sh

  $ cd "${LINUX_DIR}"
  $ "${GDB}" -iex "set auto-load safe-path scripts/gdb/" -iex "target remote localhost:5551" ./vmlinux

Enable KGDB on panic
--------------------

Usually, a debugger catches problems like segfaults and allows a user to
debug the problem further. On modern setups with kgdb, this is not the
case because the system will automatically reboot after n-seconds.

This can be avoided by changing the sysctl config ``kernel.panic`` to 0.
Either in ``/etc/sysctl.d/`` or by manually issuing

.. code-block:: sh

  sysctl -w kernel.panic=0

If a kgdb(oc) is attached then it should automatically receive a message
when the Oops was noticed and can then be debugged further.
