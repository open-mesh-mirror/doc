.. SPDX-License-Identifier: GPL-2.0

Kernel debugging over JTAG
==========================

As shown in the :doc:`Kernel debugging with qemu's GDB server <Kernel_debugging_with_qemu\'s_GDB_server>`
documentation, it is easy to debug the Linux kernel in an
:doc:`emulated system <OpenWrt_in_QEMU>`. But some problems might only be
reproducible on actual hardware
(:doc:`connected to the emulation setup <Mixing_VM_with_gluon_hardware>`). It
is therefore sometimes necessary to debug a whole system.

`JTAG <https://en.wikipedia.org/wiki/JTAG>`__ is a good way to get
access to the hardware state independent of the software currently
running on it. It is therefore a good choice when the used hardware
`exposes JTAG (or
SWD) <https://openwrt.org/docs/techref/hardware/port.jtag>`__

Requirements:

* target board which exposes JTAG

  - `the 8devices lima
    board <https://www.8devices.com/products/lima>`__ is used in this
    document

* debug adapter hardware

  - `Bus Blaster
    v3 <http://dangerousprototypes.com/docs/Bus_Blaster_v3_design_overview>`__
  - Raspberry Pi’s GPIO pins of the expansion header
  - `Bus
    Pirate <http://dangerousprototypes.com/docs/Bus_Blaster_v3_design_overview>`__
    (really slow and not recommended)
  - …

* On Chip Debugger for JTAG/SWD

  - `OpenOCD <http://openocd.org/>`__

Preparing an debug adapter hardware
-----------------------------------

The connection between the debug adapter and the target board must
established by connecting a couple of pins with each other. The color
schema used here is from the `Sparkfun Bus Pirate
cable <https://antibore.wordpress.com/2011/06/22/quick-reference-for-sparkfun-bus-pirate-cable/>`__

The debug and target board via at least following of the debug adapter
hardware:

* TDI (Test Data In)
* TDO (Test Data Out)
* TCK (Test Clock)
* TMS (Test Mode Select)
* GND (common ground)
* VTG (voltage reference)

The adapter hardware must also be selected in the OpenOCD configuration.

Only one adapter hardware must be attached. But some example
configurations are shown as reference.

Bus Blaster adapter hardware
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Bus Blaster v3 with the 20 pin header and the default buffer logic
the usage of the pins already written next to header. Just make sure to
leave the board in self powered (not closed 2 pin header)

.. image:: jtag-busblaster.svg

The configuration of the adapter hardware and the target board is also
straight forward since the release of OpenOCD 0.11

::

  cat > jtag_debug.cfg << "EOF"
  source [find interface/ftdi/dp_busblaster.cfg]
  adapter speed 2000
  transport select jtag

  # in case to start debugging session without "reset halt":
  # "reset halt" would be necessary here because otherwise the flash chip cannot
  # be detected  and the gdb attach fails with
  # "Unknown flash device (ID 0x00000000)"
  gdb_memory_map disable

  source [find board/8devices-lima.cfg]
  EOF

Raspberry PI (4 B) adapter hardware
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Raspberry PI 4B can be used as a simple adapter hardware because
there are plenty of GPIOs available and OpenOCD is able to control them
directly. Only the correctly `raw GPIO number for each
Pin <https://www.raspberrypi-spy.co.uk/2012/06/simple-guide-to-the-rpi-gpio-header-and-pins/>`__
has to be found. A good way to connect them (while keeping the SPI pins
free for reflashing SPI chips) is:

* GND: Pin 9
* TDO: GPIO17 (Pin 11)
* TDI: GPIO27 (Pin 13)
* TCK: GPIO22 (Pin 15)
* TMS: GPIO23 (Pin 16)

.. image:: jtag-rpi4.svg

The hardest part is to find the `correct base of the GPIO controller and
to set the speed settings <https://openwrt.org/toh/meraki/mr18/jtag>`__

The configuration of the adapter hardware and the target board is also
possible since the release of OpenOCD 0.11

::

  cat > jtag_debug.cfg << "EOF"
  adapter driver bcm2835gpio

  # GPIOs for: tck tms tdi tdo
  bcm2835gpio_jtag_nums 22 23 27 17

  # configuration for raspberry pi 4B
  bcm2835gpio_peripheral_base 0xFE000000
  bcm2835gpio_speed_coeffs 236181 60

  adapter speed 1000

  transport select jtag

  # in case to start debugging session without "reset halt":
  # "reset halt" would be necessary here because otherwise the flash chip cannot
  # be detected  and the gdb attach fails with
  # "Unknown flash device (ID 0x00000000)"
  gdb_memory_map disable

  source [find board/8devices-lima.cfg]


  # allow to connect via telnet/gdb to OpenOCD from actual development machine
  bindto 0.0.0.0
  EOF

Bus Pirate adapter hardware
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Bus Pirate’s SPI pins can also be used for JTAG. But it is an
extremely slow debug adapter compared to the previously mentioned ones.
For example a flash read_bank 0 flash.img 0 65536 takes 35682s when
using the 8devices lima as target board - for example, an Raspberry Pi
4B as debug adapter hardware will only need 2 minutes for the same
operations.

Just connect:

* TDO: MISO
* TDI: MOSI
* TMS: CS
* TCK: SCK
* GND: GND

The configuration of the adapter hardware and the target board is also
straight forward since the release of OpenOCD 0.11

::

  cat > jtag_debug.cfg << "EOF"
  source [find interface/buspirate.cfg]

  buspirate_vreg 0
  buspirate_mode normal
  buspirate_pullup 0

  buspirate_port /dev/ttyUSB2

  adapter speed 1000
  transport select jtag

  # in case to start debugging session without "reset halt":
  # "reset halt" would be necessary here because otherwise the flash chip cannot
  # be detected  and the gdb attach fails with
  # "Unknown flash device (ID 0x00000000)"
  gdb_memory_map disable

  source [find board/8devices-lima.cfg]
  EOF

Preparing the 8devices lima target board
----------------------------------------

The board which should run the firmware must be connected to at least
following pins of the debug adapter hardware:

-  TDI (Test Data In)
-  TDO (Test Data Out)
-  TCK (Test Clock)
-  TMS (Test Mode Select)
-  GND (common ground)
-  VTG (voltage reference)

The 8devices lima reference board exposes all over its GPIO pins:

-  TDI: J2 - GPIO1
-  TDO: J2 - GPIO2
-  TCK: J2 - GPIO0
-  TMS: J2 13 - GPIO3
-  GND: J1 16 - GND
-  VTG: J1 15 - 3.3V

.. image:: jtag-8devices-lima.svg

Preparing OpenWrt
-----------------

There is nearly no requirements from OpenWrt but there are several
things which can make the debugging a lot easier.

Enable debug info
~~~~~~~~~~~~~~~~~

The actual configuration has to be set in the target kernel
configuration:

::

   CONFIG_DEBUG_INFO=y
   CONFIG_DEBUG_INFO_DWARF4=y
   # CONFIG_DEBUG_INFO_REDUCED is not set
   CONFIG_GDB_SCRIPTS=y

The kernel address space layout randomization complicates the resolving
of addresses of symbols. It is highly recommended to start the kernel
with the parameter “nokaslr”. For example by adding it to CONFIG_CMDLINE
or by adjusting the bootargs in the bootloader. It should be checked in
/proc/cmdline whether it was really booted with this parameter.

For ar71xx (8devices lima in my case), it would look like:

.. code-block:: diff

  diff --git a/target/linux/ar71xx/config-4.14 b/target/linux/ar71xx/config-4.14
  index 9a524fae4316caa10431bd6b3b4dadbe8660f14c..397e15bcecd4e9c696a2321174969541b673cbd3 100644
  --- a/target/linux/ar71xx/config-4.14
  +++ b/target/linux/ar71xx/config-4.14
  @@ -308,10 +310,14 @@ CONFIG_CPU_SUPPORTS_MSA=y
   CONFIG_CRYPTO_RNG2=y
   CONFIG_CRYPTO_WORKQUEUE=y
   CONFIG_CSRC_R4K=y
  +CONFIG_DEBUG_INFO=y
  +CONFIG_DEBUG_INFO_DWARF4=y
  +# CONFIG_DEBUG_INFO_REDUCED is not set
   CONFIG_DMA_NONCOHERENT=y
   CONFIG_EARLY_PRINTK=y
   CONFIG_ETHERNET_PACKET_MANGLE=y
   CONFIG_FIXED_PHY=y
  +CONFIG_GDB_SCRIPTS=y
   CONFIG_GENERIC_ATOMIC64=y
   CONFIG_GENERIC_CLOCKEVENTS=y
   CONFIG_GENERIC_CMOS_UPDATE=y
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

OpenWrt will build a gdb when CONFIG_GDB=y is set in .config. But this
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
  +   -$(MAKE) -C $(HOST_BUILD_DIR)/gdb/data-directory install
   endef

   define Host/Clean
  +   -$(MAKE) -C $(HOST_BUILD_DIR)/gdb/data-directory uninstall
      rm -rf \
          $(HOST_BUILD_DIR) \
          $(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)gdb \

It is often possible (and in case of memory access/symbol relocation
problems even recommended) to just use the normal Distro’s multiarch
gdb. This would be in Debian “gdb-multiarch”.

Start debugging session
-----------------------

Starting OpenOCD
~~~~~~~~~~~~~~~~

The start of OpenOCD couldn’t be more trivial:

.. code-block:: sh

  openocd -f jtag_debug.cfg

It should start a telnet server (for manual intervention) on TCP port
4444, scan the JTAG chains and afterwards start the internal gdbserver
on port 3333.

Connecting gdb
~~~~~~~~~~~~~~

I would use following folder in my ar71xx build environment but they
will be different for other architectures or OpenWrt versions:

* ``LINUX_DIR=${OPENWRT_DIR}/build_dir/target-mips_24kc_musl/linux-ar71xx_generic/linux-4.14.236/``
* ``GDB=${OPENWRT_DIR}/staging_dir/toolchain-mips_24kc_gcc-7.5.0_musl/bin/mips-openwrt-linux-gdb``
* ``BATADV_DIR=${OPENWRT_DIR}/build_dir/target-mips_24kc_musl/linux-ar71xx_generic/batman-adv-2019.2/``

When openocd was started, we can configure gdb. It has to connect via
the local openocd gdbstub to the target device. We must change to the
LINUX_DIR first and can then start our target specific GDB with our
uncompressed kernel image.

.. code-block:: sh

  cd "${LINUX_DIR}"
  "${GDB}" -iex "set auto-load safe-path scripts/gdb/" -ex "target extended-remote localhost:3333"  ./vmlinux

The debug information for each module must be loaded using lx-symbols or
otherwise only debug information for builtin code will be accessible

::

  lx-symbols ..

  continue

You should make sure that it doesn’t load any \ **.ko files from
ipkg-**\  directories. These files are stripped and doesn’t contain the
necessary symbol information. When necessary, just delete these folders
or specify the folders with the unstripped kernel modules:

::

  lx-symbols ../batman-adv-2019.2/.pkgdir/ ../backports-4.19.66-1/.pkgdir/ ../button-hotplug/.pkgdir/

The rest of the process works similar to debugging using gdbserver. Just
set some additional breakpoints and let the kernel run again.

Some other ideas are documented in :doc:`GDB_Linux_snippets`.

The kernel hacking debian image page should also be checked to
:ref:`increasing the chance of getting debugable modules <devtools-hacking-debian-image-building-the-batman-adv-module>` which didn’t had all
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
