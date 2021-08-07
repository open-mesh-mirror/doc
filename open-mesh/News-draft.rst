.. SPDX-License-Identifier: GPL-2.0

DRAFT: Batman-adv 2021.2 released
=================================

Juli 27th, 2021. Today the B.A.T.M.A.N. team publishes the Juli 2021
update to batman-adv, TODO Also several bugfixes and code cleanups are
included in this version.

As the kernel module always depends on the Linux kernel it is compiled
against, it does not make sense to provide binaries on our website. As
usual, you will find the signed tarballs in our download section:

https://downloads.open-mesh.org/batman/releases/batman-adv-2021.2/

Thanks
------

Thanks to all people sending in patches:

* Linus Lüssing <linus.luessing@c0d3.blue>
* Shaokun Zhang <zhangshaokun@hisilicon.com>
* Simon Wunderlich <sw@simonwunderlich.de>
* Sven Eckelmann <sven@narfation.org>
* Zheng Yongjun <zhengyongjun3@huawei.com>

and to all those that supported us with good advice or rigorous testing:

* Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

batman-adv
----------

::

  $ git describe origin/master
  v2021.1-13-ge684c002
  $ range=v2021.1..v2021.1-13-ge684c002
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\|Co-authored-by\)-by'|sed 's/.*:/*/'|sort|uniq



  new kernel version
  ==================


  coding style cleanup/refactoring
  ================================

        batman-adv: Fix spelling mistakes
        batman-adv: Remove the repeated declaration
        batman-adv: Drop implicit creation of batadv net_devices
        batman-adv: Avoid name based attaching of hard interfaces
        batman-adv: Don't manually reattach hard-interface
        batman-adv: Drop reduntant batadv interface check

  various
  =======

        batman-adv: Always send iface index+name in genlmsg
        batman-adv: mcast: add MRD + routable IPv4 multicast with bridges support
        batman-adv: bcast: queue per interface, if needed
        batman-adv: bcast: avoid skb-copy for (re)queued broadcasts

  bugfixes
  ========

        batman-adv: Avoid WARN_ON timing related checks

  2021.2 (2021-07-27)
  ===================

  * support latest kernels (4.4 - 5.14)
  * coding style cleanups and refactoring
  * add MRD + routable IPv4 multicast with bridges support
  * rewrite of broadcast queuing
  * bugs squashed:

    - avoid kernel warnings on timing related checks

batctl
------

::

  $ git describe origin/master
  v2021.1-11-g041f35f
  $ range=v2021.1..v2021.1-11-g041f35f
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\|Co-authored-by\)-by'|sed 's/.*:/*/'|sort|uniq



  features
  ========



  coding style cleanup/refactoring
  ================================


        batctl: Combine command section attributes
        batctl: man: Fix alignment after json list
        batctl: man: Move commands to own section
        batctl: man: Convert lists to indented paragraph
        batctl: man: Use native list support
        batctl: man: Use tbl groff preprocessor for tables
        batctl: man: Switch to manpage font convention
        batctl: man: Add example section
        batctl: man: Reorder and restructure sections
        batctl: man: Rewrite SEE ALSO list

  bugfixes
  ========



  2021.2 (2021-07-27)
  ===================

  * manpage cleanups
  * coding style cleanups and refactoring

alfred
------

::

  $ git describe origin/master
  v2021.1-7-ge9a3bfc
  $ range=v2021.1..v2021.1-3-g40bc247
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\|Co-authored-by\)-by'|sed 's/.*:/*/'|sort|uniq


        alfred: Move IRC channel to hackint.org
        alfred: man: Fix format of interface parameter


  2021.2 (2021-07-27)
  ===================

  * manpage cleanups

Happy routing,

The B.A.T.M.A.N. team
