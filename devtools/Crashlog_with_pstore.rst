.. SPDX-License-Identifier: GPL-2.0

Crashlog with pstore
====================

The Linux kernel supports the automatic storage of stack traces for
crashes in a special memory area. This can be in a non-volatile memory
area (like the efivars) or a reserved memory area in the system ram. In
older OpenWrt releases, this was for example implemented via the
``/sys/kernel/debug/crashlog`` file which was created after a system
rebooted after a kernel panic. Newer OpenWrt releases (with kernel 5.4
or newer) don’t use the old (OpenWrt-only) implementation and the user
has to manually enable the generic kernel implementation. This is is
most cases ``PSTORE_RAM`` (previously called ramoops).

Enable PSTORE_RAM for ath79 board
---------------------------------

Enabling kernel feature
~~~~~~~~~~~~~~~~~~~~~~~

The kernel feature has to be enabled via ``make kernel_menuconfig``. The
option for it is called CONFIG_PSTORE_RAM and requires the pstore
subystem (``CONFIG_PSTORE``) to be enabled.

.. code-block:: shell

  diff --git a/target/linux/ath79/config-5.4 b/target/linux/ath79/config-5.4
  index e37b728554..7e5ee88817 100644
  --- a/target/linux/ath79/config-5.4
  +++ b/target/linux/ath79/config-5.4
  @@ -210,7 +159,23 @@ CONFIG_PHYLIB=y
   # CONFIG_PHY_AR7200_USB is not set
   # CONFIG_PHY_ATH79_USB is not set
   CONFIG_PINCTRL=y
  +CONFIG_PSTORE=y
  +# CONFIG_PSTORE_842_COMPRESS is not set
  +CONFIG_PSTORE_COMPRESS=y
  +CONFIG_PSTORE_COMPRESS_DEFAULT="deflate"
  +# CONFIG_PSTORE_CONSOLE is not set
  +CONFIG_PSTORE_DEFLATE_COMPRESS=y
  +CONFIG_PSTORE_DEFLATE_COMPRESS_DEFAULT=y
  +# CONFIG_PSTORE_LZ4HC_COMPRESS is not set
  +# CONFIG_PSTORE_LZ4_COMPRESS is not set
  +# CONFIG_PSTORE_LZO_COMPRESS is not set
  +# CONFIG_PSTORE_PMSG is not set
  +CONFIG_PSTORE_RAM=y
  +# CONFIG_PSTORE_ZSTD_COMPRESS is not set
   CONFIG_RATIONAL=y
  +CONFIG_REED_SOLOMON=y
  +CONFIG_REED_SOLOMON_DEC8=y
  +CONFIG_REED_SOLOMON_ENC8=y
   CONFIG_REGMAP=y
   CONFIG_REGMAP_MMIO=y
   CONFIG_REGULATOR=y

Reserving memory for the board
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The PSTORE_RAM is using a small RAM area for a crashlog ring-buffer. It
is recommended to use a 64KB area in the system RAM area in the address
space of the SoC which neither the bootloader nor Linux need for booting
the system. The “System RAM” region of the system can be found using cat
/proc/iomem. A good place must not conflict with any other entry in
iomem - but there can still be conflicts with the bootloader which are
not listed here. Board specific information like the data from uboot’s
bdinfo, the map files (generated using the u-boot build) and the boot
scripts must be checked here.

The old crashlog implementation used a couple of kilobytes at the 63MB
address (or the highest memory address - 1MB when the board has less
than 64MB of RAM) for the storage. This would be the 0x03f00000 address
(because the system RAM starts at 0x0 for ath79) which we can add
manually to the devicetree file of the board:

.. code-block:: diff

  --- a/target/linux/ath79/dts/xxx_xxx.dts
  +++ b/target/linux/ath79/dts/xxx_xxx.dts
  @@ -6,4 +18 @@
   #include <dt-bindings/input/input.h>

   / {
  +   reserved-memory {
  +       #address-cells = <1>;
  +       #size-cells = <1>;
  +       ranges;
  +
  +       /* 64 KiB reserved for ramoops/pstore */
  +       ramoops@03f00000 {
  +           compatible = "ramoops";
  +           reg = <0x03f00000 0x10000>;
  +           record-size = <0x1000>;
  +           console-size = <0x1000>;
  +       };
  +   };
  +
      chosen {

Other options how to specify the `ramoops region are defined in the
official
documentation <https://docs.kernel.org/admin-guide/ramoops.html>`__

The system will initialize the area on bootup:

.. code-block:: shell

  root@OpenWrt:/# dmesg|grep -e ramoops -e pstore
  [    0.134694] pstore: Registered ramoops as persistent store backend
  [    0.141271] ramoops: using 0x10000@0x3f00000, ecc: 0
  [    1.253190] pstore: Using crash dump compression: deflate

Accessing the pstore
--------------------

OpenWrt 21.02 (or newer) will automatically handle the mounting of the
pstore filesystem. For other systems, it is necessary to manually mount
the pstore using

.. code-block:: shell

  root@OpenWrt:/# /bin/mount -o noatime -t pstore pstore /sys/fs/pstore

After a kernel panic, one or more files called dmesg-ramoops-\* can be
found in the directory ``/sys/fs/pstore/``.

.. code-block:: shell

  root@OpenWrt:/# ls -ltr /sys/fs/pstore/
  -r--r--r--    1 root     root          9001 Oct 19 12:45 dmesg-ramoops-1
  -r--r--r--    1 root     root          9024 Oct 19 12:45 dmesg-ramoops-0

It should be easy to extract the relevant stacktrace from such a file.
It could for example look like this:

::

  <1>[   95.770888] CPU 0 Unable to handle kernel paging request at virtual address 00000000, epc == 8699f200, ra == 8699f1f4
  <4>[   95.781691] Oops[#1]:
  <4>[   95.783999] CPU: 0 PID: 2323 Comm: batctl Not tainted 5.4.152 #0
  <4>[   95.790082] $ 0   : 00000000 00000001 00000017 00000000
  <4>[   95.795379] $ 4   : 86f5d61c 86d7dc08 86d7dc08 869b3218
  <4>[   95.800677] $ 8   : 00000034 805464c8 86d7dc6c 00000002
  <4>[   95.805975] $12   : fffffffd 00000402 80691574 00000040
  <4>[   95.811273] $16   : 86d7dc08 86e85460 86f5d600 8689f3c0
  <4>[   95.816569] $20   : 00000000 86d7dc6c 00000000 8068fed8
  <4>[   95.821867] $24   : 00000000 86d7dde4                  
  <4>[   95.827164] $28   : 86d7c000 86d7dbc8 868cea00 8699f1f4
  <4>[   95.832463] Hi    : 00000000
  <4>[   95.835375] Lo    : 00000003
  <4>[   95.838627] epc   : 8699f200 batadv_netlink_set_mesh+0x40/0x320 [batman_adv]
  <4>[   95.846091] ra    : 8699f1f4 batadv_netlink_set_mesh+0x34/0x320 [batman_adv]
  <4>[   95.853231] Status: 1100fc03  KERNEL EXL IE 
  <4>[   95.857474] Cause : 0080000c (ExcCode 03)
  <4>[   95.861529] BadVA : 00000000
  <4>[   95.864443] PrId  : 00019750 (MIPS 74Kc)
  <4>[   95.868411] Modules linked in: ath9k ath9k_common pppoe ppp_async iptable_nat batman_adv ath9k_hw ath10k_pci ath10k_core ath xt_state xt_nat xt_conntrack xt_REDIRECT xt_MASQUERADE xt_FLOWOFFLOAD pppox ppp_generic nf_nat nf_flow_table_hw nf_flow_table nf_conntrack mac80211 ipt_REJECT cfg80211 xt_time xt_tcpudp xt_multiport xt_mark xt_mac xt_limit xt_comment xt_TCPMSS xt_LOG slhc nf_reject_ipv4 nf_log_ipv4 nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c iptable_mangle iptable_filter ip_tables crc_ccitt compat nf_log_ipv6 nf_log_common ip6table_mangle ip6table_filter ip6_tables ip6t_REJECT x_tables nf_reject_ipv6 sha256_generic libsha256 seqiv jitterentropy_rng drbg hmac ghash_generic gf128mul gcm ctr cmac ccm fsl_mph_dr_of ehci_platform ehci_fsl ehci_hcd gpio_button_hotplug usbcore nls_base usb_common crc16 aead crypto_null cryptomgr crc32c_generic crypto_hash
  <4>[   95.944865] Process batctl (pid: 2323, threadinfo=92bd6437, task=bec29b92, tls=77e34dcc)
  <4>[   95.953057] Stack : 86f5d600 869b31c8 869b4b64 86f5d600 869b31c8 869b4b64 86f5d600 8042ab40
  <4>[   95.961532]         80691570 86d7dc54 00000000 00000002 00000000 86d7dc6c 868cea00 00000913
  <4>[   95.970005]         616ebdec 00000913 86f5d600 86f5d610 86f5d614 868cea00 8068fed8 86e85460
  <4>[   95.978480]         00000000 86d7dc6c 86f5d600 8689f3c0 fffffffc 8042a96c 80670000 00000000
  <4>[   95.986955]         00000000 00000000 8042962c 80429e2c 8689f3c0 00000006 00000006 8042b2dc
  <4>[   95.995429]         ...
  <4>[   95.997905] Call Trace:
  <4>[   96.000709] [<8699f200>] batadv_netlink_set_mesh+0x40/0x320 [batman_adv]
  <4>[   96.007823] [<8042ab40>] genl_rcv_msg+0x1d4/0x4b0
  <4>[   96.012595] [<80429e2c>] netlink_rcv_skb+0xb0/0x160
  <4>[   96.017540] [<8042a630>] genl_rcv+0x30/0x48
  <4>[   96.021799] [<80429538>] netlink_unicast+0x1a4/0x298
  <4>[   96.026836] [<8042990c>] netlink_sendmsg+0x2e0/0x3c8
  <4>[   96.031877] [<803b8790>] ____sys_sendmsg+0xc4/0x26c
  <4>[   96.036823] [<803b9144>] ___sys_sendmsg+0x7c/0xcc
  <4>[   96.041595] [<803ba3fc>] sys_sendmsg+0x4c/0x94
  <4>[   96.046098] [<8006e1ac>] syscall_common+0x34/0x58
  <4>[   96.050867] Code: 0002102b  ae22000c  24020017 <a4020000> 8e020014  8c4400a8  10800004  00000000  02202825 
  <4>[   96.060751] 
  <4>[   96.062319] ---[ end trace ff181e2552b1e823 ]---
  <0>[   96.077613] Kernel panic - not syncing: Fatal exception

Decoding the stack trace
------------------------

Entries like ``batadv_netlink_set_mesh+0x40/0x320`` hard to understand when
not knowing what source code line this would be. Various tools can be
used here:

binutils’ addr2line
~~~~~~~~~~~~~~~~~~~

The ``addr2line`` can be used when the relative address is known. In our
example, the batman-adv module was loaded at address 0x86e80000 (see
``/proc/modules``). The relative address is therefore 0x0001f200
(``0x8699f200 - 0x86980000``)

.. code-block:: shell

  $ mips-linux-gnu-addr2line -f -e ./build_dir/target-mips_24kc_musl/linux-ath79_generic/batman-adv-2021.3/net/batman-adv/batman-adv.ko 0x0001f200
  batadv_netlink_set_mesh
  ./build_dir/target-mips_24kc_musl/linux-ath79_generic/batman-adv-2021.3/net/batman-adv/netlink.c:448

gdb
~~~

gdb(-multiarch) can also parse the symbols and is able to decode the
symbolic name + offset.

.. code-block:: shell

  $ gdb-multiarch -q -ex 'list *(batadv_netlink_set_mesh+0x40)' -ex quit ./build_dir/target-mips_24kc_musl/linux-ath79_generic/batman-adv-2021.3/net/batman-adv/batman-adv.ko
  Reading symbols from ./build_dir/target-mips_24kc_musl/linux-ath79_generic/batman-adv-2021.3/net/batman-adv/batman-adv.ko...
  0x1f240 is in batadv_netlink_set_mesh (./build_dir/target-mips_24kc_musl/linux-ath79_generic/batman-adv-2021.3/net/batman-adv/netlink.c:448).
  443             if (info->attrs[BATADV_ATTR_AGGREGATED_OGMS_ENABLED]) {
  444                     attr = info->attrs[BATADV_ATTR_AGGREGATED_OGMS_ENABLED];
  445
  446                     atomic_set(&bat_priv->aggregated_ogms, !!nla_get_u8(attr));
  447                     attr = NULL;
  448                     attr->nla_len = 23;
  449             }
  450
  451             if (info->attrs[BATADV_ATTR_AP_ISOLATION_ENABLED]) {
  452                     attr = info->attrs[BATADV_ATTR_AP_ISOLATION_ENABLED];

Or when trying to inspect the actual instructions together with the
source code:

.. code-block:: shell

  $ gdb-multiarch -q -ex 'disassemble /m *(batadv_netlink_set_mesh+0x40)' -ex quit ./build_dir/target-mips_24kc_musl/linux-ath79_generic/batman-adv-2021.3/net/batman-adv/batman-adv.ko
  Reading symbols from ./build_dir/target-mips_24kc_musl/linux-ath79_generic/batman-adv-2021.3/net/batman-adv/batman-adv.ko...
  Dump of assembler code for function batadv_netlink_set_mesh:
  [...]
  442
  443             if (info->attrs[BATADV_ATTR_AGGREGATED_OGMS_ENABLED]) {
     0x0001f21c <+28>:    lw      v0,20(a1)
     0x0001f220 <+32>:    lw      a0,164(v0)
     0x0001f224 <+36>:    beqz    a0,0x1f244 <batadv_netlink_set_mesh+68>
     0x0001f228 <+40>:    nop

  444                     attr = info->attrs[BATADV_ATTR_AGGREGATED_OGMS_ENABLED];

  445
  446                     atomic_set(&bat_priv->aggregated_ogms, !!nla_get_u8(attr));
     0x0001f22c <+44>:    jal     0x1d41c <nla_get_u32+8>
     0x0001f230 <+48>:    nop
     0x0001f234 <+52>:    sltu    v0,zero,v0

  447                     attr = NULL;

  448                     attr->nla_len = 23;
     0x0001f23c <+60>:    li      v0,23
     0x0001f240 <+64>:    sh      v0,0(zero)

  449             }
  [...]

Linux’s faddr2line
~~~~~~~~~~~~~~~~~~

The kernel has a script which can be used to decode one or multiple line
entries - similar to what can also be done with gdb(-multiarch).

.. code-block:: shell

  $ LXBASE=./build_dir/target-mips_24kc_musl/linux-ath79_generic
  $ CROSS_COMPILE=mips-linux-gnu- $LXBASE/linux-5.4.152/scripts/faddr2line --list $LXBASE/batman-adv-2021.3/ipkg-mips_24kc/kmod-batman-adv/lib/modules/5.4.152/batman-adv.ko  'batadv_netlink_set_mesh+0x40/0x320'
  batadv_netlink_set_mesh+0x40/0x320:

  batadv_netlink_set_mesh at ./build_dir/target-mips_24kc_musl/linux-ath79_generic/batman-adv-2021.3/net/batman-adv/netlink.c:448
   443            if (info->attrs[BATADV_ATTR_AGGREGATED_OGMS_ENABLED]) {
   444                    attr = info->attrs[BATADV_ATTR_AGGREGATED_OGMS_ENABLED];
   445 
   446                    atomic_set(&bat_priv->aggregated_ogms, !!nla_get_u8(attr));
   447                    attr = NULL;
  >448<                   attr->nla_len = 23;
   449            }
   450 
   451            if (info->attrs[BATADV_ATTR_AP_ISOLATION_ENABLED]) {
   452                    attr = info->attrs[BATADV_ATTR_AP_ISOLATION_ENABLED];
   453

Linux’s decode_stacktrace
~~~~~~~~~~~~~~~~~~~~~~~~~

The faddr2line has no real functional benefits when comparing it with
gdb. But the has another useful script which can decode the whole
stacktrace in a single run. It can even handle multiple modules when
they are under a common folder:

.. code-block:: shell

  $ LXBASE=./build_dir/target-mips_24kc_musl/linux-ath79_generic
  $ CROSS_COMPILE=mips-linux-gnu- $LXBASE/linux-5.4.152/scripts/decode_stacktrace.sh $LXBASE/linux-5.4.152/vmlinux $LXBASE/linux-5.4.152/  $LXBASE  < dmesg-ramoops-1

  [...]
  <1>[   95.770888] CPU 0 Unable to handle kernel paging request at virtual address 00000000, epc == 8699f200, ra == 8699f1f4
  <4>[   95.781691] Oops[#1]:
  <4>[   95.783999] CPU: 0 PID: 2323 Comm: batctl Not tainted 5.4.152 #0
  <4>[   95.790082] $ 0   : 00000000 00000001 00000017 00000000
  <4>[   95.795379] $ 4   : 86f5d61c 86d7dc08 86d7dc08 869b3218
  <4>[   95.800677] $ 8   : 00000034 805464c8 86d7dc6c 00000002
  <4>[   95.805975] $12   : fffffffd 00000402 80691574 00000040
  <4>[   95.811273] $16   : 86d7dc08 86e85460 86f5d600 8689f3c0
  <4>[   95.816569] $20   : 00000000 86d7dc6c 00000000 8068fed8
  <4>[   95.821867] $24   : 00000000 86d7dde4
  <4>[   95.827164] $28   : 86d7c000 86d7dbc8 868cea00 8699f1f4
  <4>[   95.832463] Hi    : 00000000
  <4>[   95.835375] Lo    : 00000003
  <4>[ 95.838627] epc : 8699f200 batadv_netlink_set_mesh (./build_dir/target-mips_24kc_musl/linux-ath79_generic/batman-adv-2021.3/net/batman-adv/netlink.c:448) batman_adv
  <4>[ 95.846091] ra : 8699f1f4 batadv_netlink_set_mesh (./build_dir/target-mips_24kc_musl/linux-ath79_generic/batman-adv-2021.3/net/batman-adv/netlink.c:446) batman_adv
  <4>[   95.853231] Status: 1100fc03      KERNEL EXL IE
  <4>[   95.857474] Cause : 0080000c (ExcCode 03)
  <4>[   95.861529] BadVA : 00000000
  <4>[   95.864443] PrId  : 00019750 (MIPS 74Kc)
  <4>[   95.868411] Modules linked in: ath9k ath9k_common pppoe ppp_async iptable_nat batman_adv ath9k_hw ath10k_pci ath10k_core ath xt_state xt_nat xt_conntrack xt_REDIRECT xt_MASQUERADE xt_FLOWOFFLOAD pppox ppp_generic nf_nat nf_flow_table_hw nf_flow_table nf_conntrack mac80211 ipt_REJECT cfg80211 xt_time xt_tcpudp xt_multiport xt_mark xt_mac xt_limit xt_comment xt_TCPMSS xt_LOG slhc nf_reject_ipv4 nf_log_ipv4 nf_defrag_ipv6 nf_defrag_ipv4 libcrc32c iptable_mangle iptable_filter ip_tables crc_ccitt compat nf_log_ipv6 nf_log_common ip6table_mangle ip6table_filter ip6_tables ip6t_REJECT x_tables nf_reject_ipv6 sha256_generic libsha256 seqiv jitterentropy_rng drbg hmac ghash_generic gf128mul gcm ctr cmac ccm fsl_mph_dr_of ehci_platform ehci_fsl ehci_hcd gpio_button_hotplug usbcore nls_base usb_common crc16 aead crypto_null cryptomgr crc32c_generic crypto_hash
  <4>[   95.944865] Process batctl (pid: 2323, threadinfo=92bd6437, task=bec29b92, tls=77e34dcc)
  <4>[   95.953057] Stack : 86f5d600 869b31c8 869b4b64 86f5d600 869b31c8 869b4b64 86f5d600 8042ab40
  <4>[   95.961532]         80691570 86d7dc54 00000000 00000002 00000000 86d7dc6c 868cea00 00000913
  <4>[   95.970005]         616ebdec 00000913 86f5d600 86f5d610 86f5d614 868cea00 8068fed8 86e85460
  <4>[   95.978480]         00000000 86d7dc6c 86f5d600 8689f3c0 fffffffc 8042a96c 80670000 00000000
  <4>[   95.986955]         00000000 00000000 8042962c 80429e2c 8689f3c0 00000006 00000006 8042b2dc
  <4>[   95.995429]         ...
  <4>[   95.997905] Call Trace:
  <4>[ 96.000709] batadv_netlink_set_mesh (./build_dir/target-mips_24kc_musl/linux-ath79_generic/batman-adv-2021.3/net/batman-adv/netlink.c:448) batman_adv
  <4>[ 96.007823] genl_rcv_msg (./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/netlink/genetlink.c:631 ./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/netlink/genetlink.c:654) 
  <4>[ 96.012595] netlink_rcv_skb (./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/netlink/af_netlink.c:2481) 
  <4>[ 96.017540] genl_rcv (./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/netlink/genetlink.c:667) 
  <4>[ 96.021799] netlink_unicast (./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/netlink/af_netlink.c:1306 ./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/netlink/af_netlink.c:1331) 
  <4>[ 96.026836] netlink_sendmsg (./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/netlink/af_netlink.c:1920) 
  <4>[ 96.031877] ____sys_sendmsg (./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/socket.c:637 ./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/socket.c:657 ./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/socket.c:2286) 
  <4>[ 96.036823] ___sys_sendmsg (./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/socket.c:2342) 
  <4>[ 96.041595] sys_sendmsg (./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/./include/linux/file.h:30 ./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/socket.c:2388 ./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/socket.c:2395 ./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/net/socket.c:2393) 
  <4>[ 96.046098] syscall_common (./build_dir/target-mips_24kc_musl/linux-ath79_generic/linux-5.4.152/arch/mips/kernel/scall32-o32.S:101) 
  <4>[ 96.050867] Code: 0002102b ae22000c 24020017 <a4020000> 8e020014 8c4400a8 10800004 00000000 02202825
  All code
  ========
     0:   0002102b        sltu    v0,zero,v0
     4:   ae22000c        sw      v0,12(s1)
     8:   24020017        li      v0,23
     c:*  a4020000        sh      v0,0(zero)              <-- trapping instruction
    10:   8e020014        lw      v0,20(s0)
    14:   8c4400a8        lw      a0,168(v0)
    18:   10800004        beqz    a0,0x2c
    1c:   00000000        nop
    20:   02202825        move    a1,s1
          ...

  Code starting with the faulting instruction
  ===========================================
     0:   a4020000        sh      v0,0(zero)
     4:   8e020014        lw      v0,20(s0)
     8:   8c4400a8        lw      a0,168(v0)
     c:   10800004        beqz    a0,0x20
    10:   00000000        nop
    14:   02202825        move    a1,s1
          ...
  <4>[   96.060751]
  <4>[   96.062319] ---[ end trace ff181e2552b1e823 ]---
  <0>[   96.077613] Kernel panic - not syncing: Fatal exception
