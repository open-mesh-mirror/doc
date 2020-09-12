.. SPDX-License-Identifier: GPL-2.0

Building B.A.T.M.A.N. Advanced with Openwrt
===========================================

Many tutorials assume that you have batman-adv running on an Openwrt
system without going into detail how to get the system built and
configured. This documents aims to fill the gap by providing a
step-by-step explanation how to get your Openwrt system up & running.

Getting the Openwrt build environment
-------------------------------------

First, you need to obtain a copy of the Openwrt build system which
contains all the build information to compile & package a complete Linux
system. You can either clone the sources via git or get tarballs from
the Openwrt project website. The various versions of Openwrt (bleeding
edge 'trunk', last stable release, previous release, etc) can be
downloaded directly from the `Openwrt
repositories <https://dev.openwrt.org/wiki/GetSource>`__.

Once downloaded change into the Openwrt directory and configure the
system to meet you needs (e.g. choose the platform and additional
packages you intend to use).

::

    cd openwrt
    make menuconfig

*Note*: The batman-adv package is not there yet because it needs to be
activated separately (see the following steps).

To build your images you always have to invoke the "make" command from
within the Openwrt folder:

::

    cd openwrt
    make

The rest of the document will focus on the batman-adv package. It is
assumed that you configured the system to work on your platform. If you
require additional information on how to tweak your Openwrt system,
please see `the Openwrt project website <https://www.openwrt.org>`__.

Adding the batman-adv / batctl package
--------------------------------------

The standard Openwrt package feed contains a batman-adv and a batctl
package which is intended to be used on a day to day basis, therefore it
retrieves the latest batman-adv / batctl stable release. Since a lot of
people want to experiment with the latest features or use Openwrt to
test their own batman-adv patches we also provide an Openwrt package
feed which contains the batman-adv development version.

stable version:

::

    scripts/feeds update
    scripts/feeds install kmod-batman-adv
    scripts/feeds install batctl

*Note*: If you downloaded an Openwrt release but intend to build the
latest batman-adv package you might need to modify your
feeds.conf(.default). Make sure you have "src-git routing
git://github.com/openwrt-routing/packages.git" instead of e.g. "src-git
routing git://github.com/openwrt-routing/packages.git;for-12.09.x".

developer version:

Append the following line to your Openwrt feed configuration file
(either feeds.conf or feeds.conf.default):

::

    src-git batman https://git.open-mesh.org/openwrt-feed-devel.git

Update the package information and add the development package:

::

    scripts/feeds update
    scripts/feeds install kmod-batman-adv-devel
    scripts/feeds install batctl-devel

Configuring the batman-adv package
----------------------------------

As soon as the batman-adv package has been added, it will show up in the
Openwrt package menu:

stable version:

::

    Kernel modules ---> 
       Network Support ---> 
          kmod-batman-adv

developer version:

::

    Kernel modules ---> 
       Network Support ---> 
          kmod-batman-adv-devel

Once the package had been selected a number of suboptions will become
visible. You can enable/disable the verbose debug logging as well as
choose whether or not to include the batctl tool.

In addition, the batman-adv package comes with an init script which is
installed per default. This script will run at boot time and can be used
to configure your desired batman-adv options. It reads the batman-adv
uci file to retrieve the settings which allows to specify interfaces,
intervals, log level and more.

Basic configuration: :doc:`batman-adv Openwrt config <Batman-adv-openwrt-config>`

Rebuilding the package
----------------------

If you experience build problems or simply intend to rebuild the
batman-adv package only, you can tell Openwrt to build a specific
package and enable the debugging mode as follows:

stable version:

::

    cd openwrt
    make package/batman-adv/clean
    make package/batman-adv/compile V=99

developer version:

::

    cd openwrt
    make package/batman-adv-devel/clean
    make package/batman-adv-devel/compile V=99

Applying patches
----------------

The package offers an easy way to apply custom patches whenever
batman-adv is built. Simply copy your patches into the "patches" folder
inside the package directory (you have to create the folder in case it
does not exist yet). Patch files having the string 'batman' in their
name are applied to batman-adv whereas patches containing the string
'batctl' are applied to the batctl tool. The location of the folder
depends on which package you want to patch:

stable version:

::

    openwrt/feeds/packages/net/batman-adv/patches

developer version:

::

    openwrt/feeds/batman/batman-adv-devel/patches

Changing the batman-adv / batctl version
----------------------------------------

It is also possible to modify the batman-adv version if you ever wanted
to build an older/newer version than configured in the package:

stable version:

Adjust the PKG\_VERSION variable configured in the package Makefile to
download & build the stable release you are interested in.

cat openwrt/feeds/routing/batman-adv/Makefile

::

    [..]
    PKG_VERSION:=2013.4.0
    [..]

you will probably want to change md5sum also:

::

    [..]
    PKG_MD5SUM:=1a2b3c4d5e6f7g # https://downloads.open-mesh.org/batman/releases/batman-adv-2013.4.0/batman-adv-2013.4.0.tar.gz.md5
    [..]

And if you want to match batman-adv version with batctl version, do the
similar thing for the next lines:

::

    [..]
    BATCTL_VERSION:=2013.4.0
    [..]

::

    [..]
    PKG_MD5SUM:=1a2b3c4d5e6f7g # https://downloads.open-mesh.org/batman/releases/batman-adv-2013.4.0/batctl-2013.4.0.tar.gz.md5
    [..]

And be careful when changing versions, your build may fail. Build with
make V=99 so you can see what is going on, and if applying some
batman-adv patch fails, locate it under
/home/user/openwrt/feeds/routing/batman-adv/patches and remove it.

developer version:

Adjust the batman-adv & batctl git branch / tag via the Openwrt
configuration menu (aka "make menuconfig") to download & build the git
revision you are interested in:

::

    Kernel modules ---> 
       Network Support ---> 
          kmod-batman-adv-devel
            batman-adv branch

Building from a different branch
--------------------------------

The developer package offers a convenient way to select another branch
to build from. This is particularly useful for testing features that
have not been merged into the master branch yet. Simply enter the branch
or git tag you wish to build in the Openwrt build menu.

Kernel crash debug
------------------

In case you experience kernel oopses it might prove helpful to enable
the kernel symbol table which translates the cryptic numbers which are
part of each kernel oops log into readable function names. This
calltrace can help developers to analyze the problem. Use Openwrt's
config menu to enable the kernel symbol table and rebuild your image:

::

    make menuconfig
    Global build settings --->
       Compile the kernel with symbol table information

If you can't find this option you are using an older Openwrt version
which doesn't offer this config switch in the main menu. You have to
modify the kernel settings directly:

::

    make kernel_menuconfig
    General setup --->
       Configure standard kernel features (for small systems) --->
          Load all symbols for debugging/ksymoops
