.. SPDX-License-Identifier: GPL-2.0

DRAFT: Batman-adv 2017.2 released
=================================

July 26th, 2017. Today the B.A.T.M.A.N. team publishes the July 2017
update to batman-adv, batctl and alfred! This release **TODO**

As the kernel module always depends on the Linux kernel it is compiled
against, it does not make sense to provide binaries on our website. As
usual, you will find the signed tarballs in our download section:

https://downloads.open-mesh.org/batman/releases/batman-adv-2017.2/

Thanks
------

Thanks to all people sending in patches:

-  Antonio Quartulli <a@unstable.cc>
-  David S. Miller <davem@davemloft.net>
-  Joe Perches <joe@perches.com>
-  Johannes Berg <johannes.berg@intel.com>
-  Markus Elfring <elfring@users.sourceforge.net>
-  Philipp Psurek <philipp.psurek@gmail.com>
-  Simon Wunderlich <sw@simonwunderlich.de>
-  Sven Eckelmann <sven@narfation.org>

batman-adv
----------

::

    $ git describe origin/master
    v2017.1-17-g6e94ef82
    $ git shortlog --email --no-merges v2017.1..v2017.1-17-g6e94ef82

    features?
    ========

          batman-adv: do not add loop detection mac addresses to global tt


    bugfixes
    ========

          batman-adv: Use default throughput value on cfg80211 error
          batman-adv: Accept only filled wifi station info

    coding style cleanup/refactoring
    ================================

          batman-adv: tp_meter: mark init function with __init
          batman-adv: Fix inconsistent teardown and release of private netdev state.
          batman-adv: Remove unnecessary length qualifier in %14pM
          batman-adv: convert many more places to skb_put_zero()
          batman-adv: introduce and use skb_put_data()
          batman-adv: make skb_put & friends return void pointers
          batman-adv: Replace a seq_puts() call by seq_putc() in two functions
          batman-adv: Combine two seq_puts() calls into one call in batadv_nc_nodes_seq_print_text()
          batman-adv: simplify return handling in some TT functions
          batman-adv: Print correct function names in dbg messages

    batman-adv 2017.2

     * support latest kernels (3.2 - 4.13)

     -- Wed, 26 Jul 2017 18:11:55 +0100

batctl
------

::

    $ git describe origin/master
    v2017.1-4-g5fb3a49
    $ git shortlog --email --no-merges v2017.1..v2017.1-4-g5fb3a49

    bugfixes
    ========

          batctl: Fix error message when tcpdump packet send failed

    cleanup
    =======

          batctl: change PATH_BUFF_LEN to maximal possible value
          batctl: suppress implicit-fallthrough compiler warning


    batctl 2017.2

     -- Wed, 26 Jul 2017 18:11:55 +0100

alfred
------

::

    $ git describe origin/master
    v2017.1-9-g50a8923
    $ git shortlog --email --no-merges v2017.1..v2017.1-9-g50a8923

    features
    ========

          alfred: Only query tq of remote master in slave mode
          alfred: Check the TQ of master servers before pushing data
          alfred: Cache the TQ values for each originator
          alfred: Cache the global translation table entries

    cleanup
    =======

          alfred: Move alfred specific netlink code in separate file

    alfred 2017.2:


     -- Wed, 26 Jul 2017 18:11:55 +0100

Happy routing,

The B.A.T.M.A.N. team
