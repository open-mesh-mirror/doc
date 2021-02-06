.. SPDX-License-Identifier: GPL-2.0

DRAFT: Batman-adv 2021.0 released
=================================

Jan 5th, 2021. Today the B.A.T.M.A.N. team publishes the January 2021
update to batman-adv, batctl and alfred! The deprecated support for
batman-adv’s sysfs and debugfs files was removed from all components.
batctl and batman-adv now also allow the selection of the routing
algorithm during the interface creation. This can be used to avoid the
undefined behavior when multiple processes trying to create interfaces
with different routing algorithms. Also several bugfixes and code
cleanups are included in this version.

As the kernel module always depends on the Linux kernel it is compiled
against, it does not make sense to provide binaries on our website. As
usual, you will find the signed tarballs in our download section:

https://downloads.open-mesh.org/batman/releases/batman-adv-2021.0/

Thanks
------

Thanks to all people sending in patches:

* Sven Eckelmann <sven@narfation.org>
* Simon Wunderlich <sw@simonwunderlich.de>
* Taehee Yoo <ap420073@gmail.com>

and to all those that supported us with good advice or rigorous testing:

* Linus Lüssing <linus.luessing@c0d3.blue>

batman-adv
----------

::

  $ git describe origin/master
  v2020.4-15-g47df68d0
  $ range=v2020.4..v2020.4-15-g47df68d0
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\|Co-authored-by\)-by'|sed 's/.*:/*/'|sort|uniq


  coding style cleanup/refactoring
  ================================

        batman-adv: Drop deprecated sysfs support
        batman-adv: Drop deprecated debugfs support
        batman-adv: Drop legacy code for auto deleting mesh interfaces
        batman-adv: Drop unused soft-interface.h include in fragmentation.c
        batman-adv: Add new include for min/max helpers

  various
  =======

        batman-adv: Prepare infrastructure for newlink settings
        batman-adv: Allow selection of routing algorithm over rtnetlink

  bugfixes
  ========

        (batman-adv: set .owner to THIS_MODULE)
        batman-adv: Consider fragmentation for needed_headroom
        batman-adv: Reserve needed_*room for fragments
        batman-adv: Don't always reallocate the fragmentation skb head


  2021.0 (2021-01-05)
  ===================

  * support latest kernels (4.4 - 5.11)
  * coding style cleanups and refactoring
  * drop support for sysfs+debugfs
  * allow to select routing algorithm during creation of interface
  * bugs squashed:

    - allocate enough reserved room on fragments for lower devices

batctl
------

::

  $ git describe origin/master
  v2020.4-10-ga0da92b
  $ range=v2020.4..v2020.4-10-ga0da92b
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\|Co-authored-by\)-by'|sed 's/.*:/*/'|sort|uniq


  features
  ========

        batctl: Allow to configure routing_algo during interface creation

  coding style cleanup/refactoring
  ================================

        batctl: Switch active routing algo list to netlink
        batctl: Drop deprecated debugfs support
        batctl: Drop deprecated sysfs support

  bugfixes
  ========

        batctl: Fix retrieval of meshif ap_isolation
        batctl: Don't stop when create_interface detected existing interface


  2021.0 (2021-01-05)
  ===================

  * Drop support for batman-adv's sysfs+debugfs
  * allow to select routing algorithm during creation of interface
  * bugs squashed:

    - fix query of meshif's ap_isolation status
    - ignore "interface already exists" error during "interface add"

alfred
------

::

  $ git describe origin/master
  v2020.4-5-gbdd9fc8
  $ range=v2020.4..v2020.4-5-gbdd9fc8
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\|Co-authored-by\)-by'|sed 's/.*:/*/'|sort|uniq



        alfred: Drop deprecated debugfs support
        alfred: Drop deprecated sysfs support
        alfred: Sync batman-adv netlink uapi header


  2021.0 (2021-01-05)
  ===================

  * Drop support for batman-adv's sysfs+debugfs

Happy routing,

The B.A.T.M.A.N. team
