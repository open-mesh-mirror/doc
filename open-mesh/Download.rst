.. SPDX-License-Identifier: GPL-2.0

Download B.A.T.M.A.N.
=====================

We are currently working on different branches. To get the details about
the differences of these branches, see our :doc:`Branches Explained page <BranchesExplained>`.

Please use the stable branch for your public infrastructure unless you
know exactly what you are doing and are prepared for the big unknown.

.. _open-mesh-download-download-released-source-code:

Download Released Source Code
-----------------------------

-  The latest version of batman-adv is
   `batman-adv-2025.0.tar.gz <https://downloads.open-mesh.org/batman/stable/sources/batman-adv/batman-adv-2025.0.tar.gz>`__
   `md5 <https://downloads.open-mesh.org/batman/stable/sources/batman-adv/batman-adv-2025.0.tar.gz.md5>`__
   `sha1 <https://downloads.open-mesh.org/batman/stable/sources/batman-adv/batman-adv-2025.0.tar.gz.sha1>`__
   `asc <https://downloads.open-mesh.org/batman/stable/sources/batman-adv/batman-adv-2025.0.tar.gz.asc>`__
-  The latest version of batctl (management and control tool for
   batman-adv) is
   `batctl-2025.0.tar.gz <https://downloads.open-mesh.org/batman/stable/sources/batctl/batctl-2025.0.tar.gz>`__
   `md5 <https://downloads.open-mesh.org/batman/stable/sources/batctl/batctl-2025.0.tar.gz.md5>`__
   `sha1 <https://downloads.open-mesh.org/batman/stable/sources/batctl/batctl-2025.0.tar.gz.sha1>`__
   `asc <https://downloads.open-mesh.org/batman/stable/sources/batctl/batctl-2025.0.tar.gz.asc>`__
-  The latest version of alfred (Almighty Lightweight Fact Remote
   Exchange Daemon) is
   `alfred-2025.0.tar.gz <https://downloads.open-mesh.org/batman/stable/sources/alfred/alfred-2025.0.tar.gz>`__
   `md5 <https://downloads.open-mesh.org/batman/stable/sources/alfred/alfred-2025.0.tar.gz.md5>`__
   `sha1 <https://downloads.open-mesh.org/batman/stable/sources/alfred/alfred-2025.0.tar.gz.sha1>`__
   `asc <https://downloads.open-mesh.org/batman/stable/sources/alfred/alfred-2025.0.tar.gz.asc>`__

-  The latest stable version of batmand
   (:ref:`unmaintained <open-mesh-BranchesExplained-batmand>`) is
   `batman-0.3.2.tar.gz <https://downloads.open-mesh.org/batman/releases/batman-0.3.2/batman-0.3.2.tar.gz>`__
   `md5 <https://downloads.open-mesh.org/batman/releases/batman-0.3.2/batman-0.3.2.tar.gz.md5>`__
   `sha1 <https://downloads.open-mesh.org/batman/releases/batman-0.3.2/batman-0.3.2.tar.gz.sha1>`__
   `asc <https://downloads.open-mesh.org/batman/releases/batman-0.3.2/batman-0.3.2.tar.gz.asc>`__
-  The latest version of the vis server for the batmand (package not
   needed for batman-adv) is
   `vis-0.3.2.tar.gz <https://downloads.open-mesh.org/batman/releases/batman-0.3.2/vis-0.3.2.tar.gz>`__
   `md5 <https://downloads.open-mesh.org/batman/releases/batman-0.3.2/vis-0.3.2.tar.gz.md5>`__
   `sha1 <https://downloads.open-mesh.org/batman/releases/batman-0.3.2/vis-0.3.2.tar.gz.sha1>`__
   `asc <https://downloads.open-mesh.org/batman/releases/batman-0.3.2/vis-0.3.2.tar.gz.asc>`__

If you are wondering whether batman-adv or batmand might suit your setup
better, have a look at :doc:`this page </batman-adv/Wiki>`. Please note that
the development is focusing on batman-adv at the moment.

To download previous release tarballs, simply check out our `download
section <https://downloads.open-mesh.org/batman/releases/>`__.

If you find any bugs, please :doc:`let us know <Contribute>`!

Git Repository Access
---------------------

Since we started integrating the batman-adv kernel module into the
mainline Linux tree, we maintain a git repository which contains the
batman-adv maintenance branches. More information can be found
:doc:`on our git page <UsingBatmanGit>`.
On overview about all the git repositories can be found on our `git
frontend <https://git.open-mesh.org>`__. We also host individual
repositories for development related to batman or meshing in general.
Feel free to contact us if you are interested in getting a repository
too.

batman-adv in the Linux tree
----------------------------

Since linux 2.6.33 batman-adv is part of the official linux tree. You
can build batman-adv along with your linux binary by simply selecting
batman-adv in the Linux drivers section. If you want to have access to
the latest features on a non-bleeding edge kernel, you can clone our
git repository which still are backward compatible to all
stable/longterm kernels.

It follows an overview of linux versions and the batman-adv version they
contain, so that you can easily pick the compatible batctl packages:

-  linux 2.6.33 => batman-adv 0.2.0 (get batctl 0.2.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 2.6.34 => batman-adv 0.2.1 (get batctl 0.2.1 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 2.6.35 => batman-adv 2010.0.x (get batctl 2010.0.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 2.6.36 => batman-adv 2010.1.x (get batctl 2010.1.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 2.6.37 => batman-adv 2010.2.x (get batctl 2010.2.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 2.6.38 => batman-adv 2011.0.x (get batctl 2011.0.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 2.6.39 => batman-adv 2011.1.x (get batctl 2011.1.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.0 => batman-adv 2011.2.x (get batctl 2011.2.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.1 => batman-adv 2011.3.x (get batctl 2011.3.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.2 => batman-adv 2011.4.x (get batctl 2011.4.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.3 => batman-adv 2012.0.x (get batctl 2012.0.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.4 => batman-adv 2012.1.x (get batctl 2012.1.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.5 => batman-adv 2012.2.x (get batctl 2012.2.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.6 => batman-adv 2012.3.x (get batctl 2012.3.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.7 => batman-adv 2012.4.x (get batctl 2012.4.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.8 => batman-adv 2013.0.x (get batctl 2013.0.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.9 => batman-adv 2013.1.x (get batctl 2013.1.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.10 => batman-adv 2013.2.x (get batctl 2013.2.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.11 => batman-adv 2013.3.x (get batctl 2013.3.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.12 => batman-adv 2013.4.x (get batctl 2013.4.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.13 => batman-adv 2014.0.x (get batctl 2014.0.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
   NOTE: in-kernel version number is 2013.5.0
-  linux 3.14 => batman-adv 2014.1.x (get batctl 2014.1.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.15 => batman-adv 2014.2.x (get batctl 2014.2.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.16 => batman-adv 2014.3.x (get batctl 2014.3.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 3.17-3.19 => batman-adv 2014.4.x (get batctl 2014.4.x from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.0-4.1 => batman-adv 2015.0 (get batctl 2015.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/>`__
-  linux 4.2-4.3 => batman-adv 2015.1 (get batctl 2015.1 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.4 => batman-adv 2015.2 (get batctl 2015.2 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.5 => batman-adv 2016.0 (get batctl 2016.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.6 => batman-adv 2016.1 (get batctl 2016.1 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.7 => batman-adv 2016.2 (get batctl 2016.2 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.8 => batman-adv 2016.3 (get batctl 2016.3 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.9 => batman-adv 2016.4 (get batctl 2016.4 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.10 => batman-adv 2016.5 (get batctl 2016.5 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.11 => batman-adv 2017.0.1 (get batctl 2017.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.12 => batman-adv 2017.1 (get batctl 2017.1 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.13 => batman-adv 2017.2 (get batctl 2017.2 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.14 => batman-adv 2017.3 (get batctl 2017.3 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.15 => batman-adv 2017.4 (get batctl 2017.4 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.16 => batman-adv 2018.0 (get batctl 2018.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.17 => batman-adv 2018.1 (get batctl 2018.1 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.18 => batman-adv 2018.2 (get batctl 2018.2 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.19 => batman-adv 2018.3 (get batctl 2018.3 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 4.20 => batman-adv 2018.4 (get batctl 2018.4 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.0 => batman-adv 2019.0 (get batctl 2019.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.1 => batman-adv 2019.1 (get batctl 2019.1 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.2 => batman-adv 2019.2 (get batctl 2019.2 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.3 => batman-adv 2019.3 (get batctl 2019.3 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.4 => batman-adv 2019.4 (get batctl 2019.4 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.5 => batman-adv 2019.5 (get batctl 2019.5 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.6 => batman-adv 2020.0 (get batctl 2020.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.7 => batman-adv 2020.1 (get batctl 2020.1 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.8 => batman-adv 2020.2 (get batctl 2020.2 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.9 => batman-adv 2020.3 (get batctl 2020.3 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.10 => batman-adv 2020.4 (get batctl 2020.4 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.11 => batman-adv 2021.0 (get batctl 2021.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.13 => batman-adv 2021.1 (get batctl 2021.1 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.14 => batman-adv 2021.2 (get batctl 2021.2 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.15 => batman-adv 2021.3 (get batctl 2021.3 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.16 => batman-adv 2021.4 (get batctl 2021.4 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.17 => batman-adv 2022.0 (get batctl 2022.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.18 => batman-adv 2022.1 (get batctl 2022.1 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 5.19 => batman-adv 2022.2 (get batctl 2022.2 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.1 => batman-adv 2022.3 (get batctl 2022.3 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.2 => batman-adv 2023.0 (get batctl 2023.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.3 => batman-adv 2023.0 (get batctl 2023.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.4 => batman-adv 2023.1 (get batctl 2023.1 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.5 => batman-adv 2023.2 (get batctl 2023.2 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.6 => batman-adv 2023.3 (get batctl 2023.3 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.7 => batman-adv 2023.3 (get batctl 2023.3 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.8 => batman-adv 2024.0 (get batctl 2024.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.9 => batman-adv 2024.1 (get batctl 2024.1 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.10 => batman-adv 2024.2 (get batctl 2024.2 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.11 => batman-adv 2024.2 (get batctl 2024.2 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.12 => batman-adv 2024.3 (get batctl 2024.3 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.13 => batman-adv 2024.4 (get batctl 2024.4 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__
-  linux 6.14 => batman-adv 2025.0 (get batctl 2025.0 from
   `here <https://downloads.open-mesh.org/batman/stable/sources/batctl/)>`__

Arch Linux
----------

Batman-adv and Batctl are avaible in the
`AUR <https://wiki.archlinux.org/index.php/AUR>`__ as PKGBUILD:

-  `batctl <https://aur.archlinux.org/packages/batctl/>`__ - Latest
   Batctl
-  `batman-adv <https://aur.archlinux.org/packages/batman-adv/>`__ -
   Latest Batman-adv
-  `batman-adv-v14 <https://aur.archlinux.org/packages/batman-adv-v14/>`__
   - Last Batman-adv with compability-version 14 (2013.4)
-  `batctl-v14 <https://aur.archlinux.org/packages/batctl-v14/>`__ -
   Last Batctl with compability-version 14 (2013.4)

Debian
------

Use apt-get (or any other dpkg frontend of choice) to install
B.A.T.M.A.N. onto your debian machine. Following packages are available:

-  `alfred <https://packages.debian.org/sid/alfred>`__
-  `batmand <https://packages.debian.org/sid/batmand>`__
-  `batctl <https://packages.debian.org/sid/batctl>`__
-  `linux <https://packages.debian.org/source/unstable/linux>`__ -
   batman-advanced kernel module as `part of the
   official <https://bugs.debian.org/622361>`__ kernel packages

Similar packages are also available through `Ubuntu
universe <https://help.ubuntu.com/community/Repositories/Ubuntu>`__ .

Gentoo
------

Use emerge to build B.A.T.M.A.N. on your gentoo machine. Following
ebuilds are available:

-  `net-misc/batctl <https://packages.gentoo.org/packages/net-misc/batctl>`__
-  `net-misc/batman-adv <https://packages.gentoo.org/packages/net-misc/batman-adv>`__

openSUSE
--------

-  `network:utilities /
   batctl <https://build.opensuse.org/package/show?package=batctl&project=network%3Autilities>`__
-  the batman-adv module is available as module in the official kernel
   packages

Building OpenWRT packages
-------------------------

B.A.T.M.A.N. is also included in OpenWRT as a package. Download the
extra package feed, link the batman folder into your main OpenWRT svn
directory and use "make menuconfig" to select the B.A.T.M.A.N. flavor
you intend to use. This enables you to integrate B.A.T.M.A.N. seamlessly
into your builds (see  :doc:`this page </batman-adv/Building-with-openwrt>` for
a detailed explanation).

More information about how to build the OpenWRT toolchain is available
`here <https://wiki.openwrt.org/doc/howto/build>`__.
