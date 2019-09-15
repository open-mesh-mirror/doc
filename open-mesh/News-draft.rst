.. SPDX-License-Identifier: GPL-2.0

DRAFT: Batman-adv 2018.3 released
=================================

Aug 27th, 2018. Today the B.A.T.M.A.N. team publishes the August 2018 update to
batman-adv, batctl and alfred! TODO

As the kernel module always depends on the Linux kernel it is compiled against,
it does not make sense to provide binaries on our website. As usual, you will
find the signed tarballs in our download section:

https://downloads.open-mesh.org/batman/releases/batman-adv-2018.3/

Thanks
------

Thanks to all people sending in patches:

* Antonio Quartulli <a@unstable.cc>
* Joe Perches <joe@perches.com>
* Simon Wunderlich <sw@simonwunderlich.de>
* Sven Eckelmann <sven@narfation.org>

and to all those that supported us with good advice or rigorous testing:

* Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

batman-adv
----------

::

  $ git describe origin/master
  v2018.2-9-g89dcbd5f
  $ range=v2018.2..v2018.2-9-g89dcbd5f
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\)-by'|sed 's/.*:/*/'|sort|uniq
  
  new kernel support
  ==================
  
        batman-adv: Convert random_ether_addr to eth_random_addr
  
  coding style cleanup/refactoring
  ================================
  
        batman-adv: fix checkpatch warning about misspelled "cache"
        batman-adv: Unify include guards style
        batman-adv: Join batadv_purge_orig_ref and _batadv_purge_orig
        batman-adv: Convert batadv_dat_addr_t to proper type
        batman-adv: Drop "experimental" from BATMAN_V Kconfig
        batman-adv: Remove "default n" in Kconfig
  
  
  multicast
  =========
  
  
  unclassified
  ============
  
        batman-adv: enable DAT by default at compile time
  
  
  
  bugfixes
  ========
  
  
  
  
  
  
  2018.3 (2018-08-27)
  ===================
  
  * support latest kernels (3.16 - 4.19)
  * coding style cleanups and refactoring
  * enable the DAT by default for the in-tree Linux module


batctl
------

::

  $ git describe origin/master
  v2018.2-1-g15893f1
  $ range=v2018.2..v2018.2-1-g15893f1
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\)-by'|sed 's/.*:/*/'|sort|uniq
  
  
  
  
  2018.3 (2018-08-27)
  ===================
  
  * (no changes)

alfred
------

::

  $ git describe origin/master
  v2018.2-1-gbd9b383
  $ range=v2018.2..v2018.2-1-gbd9b383
  $ git shortlog --email --no-merges "${range}"
  $ git log --no-merges "${range}"|grep -e '\(Reported\|Tested\|Acked\|Reviewed-by\)-by'|sed 's/.*:/*/'|sort|uniq
  
  
  
  2018.3 (2018-08-27)
  ===================
  
  * (no changes)


Happy routing,

The B.A.T.M.A.N. team
