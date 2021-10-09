.. SPDX-License-Identifier: GPL-2.0

Analyzing virtual network packets
=================================

Wireshark
---------

The easiest way to get the traffic of a virtual machine is via the tap
interfaces. It is recommended to use the newest wireshark version (git
master branch) to get support for batman-adv’s packet format. Wireshark
can then be started manually on a specific tap interface:

.. code-block:: sh

  wireshark -k -i tap1

View traffic via wireshark from virtual machine
-----------------------------------------------

It is not always possible to use the tap interface because either the
packets are filtered somewhere in the path from/to the virtual machine.
Or sometimes the packets are not even supposed to leave the virtual
machine (for example with veth or hwsim). But is it also possible to
start tcpdump inside the virtual machine via ssh and send the captured
data to a local fifo (named pipe) on the host machine. Wireshark can
read from the pipe and show the captured data

.. code-block:: sh

  mkfifo remote-dump
  ssh root@192.168.251.51 'tcpdump -i enp0s1 -s 0 -U -n -w - "port not 22"' > remote-dump
  wireshark -k -i remote-dump
