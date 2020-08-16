.. SPDX-License-Identifier: GPL-2.0

DRAFT: Batman-adv 2020.3 released
=================================

Aug 25th, 2020. Today the B.A.T.M.A.N. team publishes the August 2020
update to batman-adv, batctl and alfred! An additional hop penalty can
now be configured on a per interface basis. Also several bugfixes and
code cleanups are included in this version.

As the kernel module always depends on the Linux kernel it is compiled
against, it does not make sense to provide binaries on our website. As
usual, you will find the signed tarballs in our download section:

https://downloads.open-mesh.org/batman/releases/batman-adv-2020.3/

Thanks
------

Thanks to all people sending in patches:

* Linus Lüssing <linus.luessing@c0d3.blue>
* Simon Wunderlich <sw@simonwunderlich.de>
* Sven Eckelmann <sven@narfation.org>

and to all those that supported us with good advice or rigorous testing:

* Antonio Quartulli <a@unstable.cc>

batman-adv
----------

::

  $ git describe origin/master
  v2020.2-7-geded19e9
  $ range=v2020.2..v2020.2-7-geded19e9
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\|Co-authored-by\)-by'|sed 's/.*:/*/'|sort|uniq


  coding style cleanup/refactoring
  ================================

        batman-adv: Switch mailing list subscription page
        batman-adv: Fix typos and grammar in documentation

  various
  =======

        batman-adv: Introduce a configurable per interface hop penalty

  bugfixes
  ========

        batman-adv: Avoid uninitialized chaddr when handling DHCP
        batman-adv: Fix own OGM check in aggregated OGMs



  2020.3 (2020-08-25)
  ===================

  * support latest kernels (4.4 - 5.9)
  * coding style cleanups and refactoring
  * introduce a configurable per interface hop penalty
  * bugs squashed:

    - avoid uninitialized chaddr when handling DHCP
    - fix own OGMv2 check in aggregation receive handling

batctl
------

::

  $ git describe origin/master
  v2020.2-3-g2c893e3
  $ range=v2020.2..v2020.2-3-g2c893e3
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\|Co-authored-by\)-by'|sed 's/.*:/*/'|sort|uniq


  various
  =======

        batctl: Add per interface hop penalty command


  2020.3 (2020-08-25)
  ===================

  * add per interface hop penalty command

alfred
------

::

  $ git describe origin/master
  v2020.2-2-g921940b
  $ range=v2020.2..v2020.2-2-g921940b
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\|Co-authored-by\)-by'|sed 's/.*:/*/'|sort|uniq

  Sven Eckelmann <sven@narfation.org> (1):
        batctl: Sync batman-adv netlink uapi header

  2020.3 (2020-08-25)
  ===================

  * synchronization of batman-adv netlink header

Happy routing,

The B.A.T.M.A.N. team
