.. SPDX-License-Identifier: GPL-2.0

Kernel debugging with qemu’s GDB server
=======================================

General
-------

The instances from :doc:`OpenWrt_in_QEMU` are listening on 127.0.0.1 TCP
port 23000 + instance_no. We will use in the following example instance
number 1. It is also assumed that the :doc:`Kernel_hacking_Debian_image` is
used as for this VM. The gdb debugger can be started from the linux
source directory and all lx-\* helpers will automatically be loaded.

Debugging Session
-----------------

The debugging session with gdb can be started from the linux-next
directory:

.. code-block:: sh

  gdb -iex "set auto-load safe-path scripts/gdb/" -ex 'target remote 127.0.0.1:23001' -ex c  ./vmlinux

The module can now be loaded in the qemu instance as normal. But after
that, we have to reload the symbol information via lx-symbol. This
allows us to set any kind of breakpoints on the batman-adv module and to
to get useful backtraces in gdb:

::

  ^C
  Thread 1 received signal SIGINT, Interrupt.
  default_idle () at arch/x86/kernel/process.c:581
  581             trace_cpu_idle_rcuidle(PWR_EVENT_EXIT, smp_processor_id());
  
  
  (gdb) lx-symbols /home/sven/tmp/qemu-batman/batman-adv/net/batman-adv/
  loading vmlinux
  scanning for modules in /home/sven/tmp/qemu-batman/batman-adv/net/batman-adv/
  scanning for modules in /home/sven/tmp/qemu-batman/linux-next
  loading @0xffffffffa0000000: /home/sven/tmp/qemu-batman/batman-adv/net/batman-adv//batman-adv.ko
  
  (gdb) b batadv_iv_send_outstanding_bat_ogm_packet
  Breakpoint 1 at 0xffffffffa0005d60: file /home/sven/tmp/qemu-batman/batman-adv/net/batman-adv/bat_iv_ogm.c, line 1692.
  (gdb) c
