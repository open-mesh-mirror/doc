.. SPDX-License-Identifier: GPL-2.0

Bridge loop avoidance protocol description
==========================================

Further pages on this topic:

* :doc:`Bridge-loop-avoidance-Testcases <Bridge-loop-avoidance-Testcases>` Test case descriptions
* :doc:`Bridge-loop-avoidance-II <Bridge-loop-avoidance-II>` Technical description
* :doc:`Bridge-loop-avoidance <Bridge-loop-avoidance>` User howto

Claim frames
------------

|image0|

All claim operations are sent using "special" gratuitous ARP frames. 4
types are used which are illustrated above:

* CLAIM frames are used to tell others that a backbone gateway feels
  responsible for a client now
* UNCLAIM frames are sent when a backbone gateway does not feel
  responsible anymore
* ANNOUNCE frames are sent regularly to find other backbone gateways
  and provides the CRC of its local table
* REQUEST frames are used to ask for a full table update when the
  information is out of sync (i.e. the announced CRC does not match with
  the local CRC)

The claim type is announced within the 4th byte of the Target HW
address.

*Note:* Although this is a misuse of ARP packets, the "normal" ARP
process should not be disturbed as the IP addresses (0.0.0.0) should not
be in any sane ARP table. As far as I understand, a gratuitous ARP
should only be considered if the IP address is already in an ARP table
[2].

[1] https://tools.ietf.org/html/rfc826
[2] https://tools.ietf.org/html/rfc2002#section-4.6

CLAIM frames
~~~~~~~~~~~~

::

      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet DST: FF:FF:FF:FF:FF:FF                            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet DST (cont)        |  Ethernet Source: client addr |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet SRC: client addr (cont)                           |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet type: 08 06       |  HW type: 00 01               |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Protocol type: 08 00       |  HW size: 06  | Prot size: 04 |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Opcode: 02 = Reply         |  Sender HW addr: orig addr    |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Sender HW addr: originator addr (cont)                     |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Sender IP: 0.0.0.0                                         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target HW addr: FF:43:05:00:XX:XX                          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target HW addr (cont)      | Target IP: 0.0.0.0            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target IP: 0.0.0.0 (cont)  | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

A CLAIM frame is sent when a new client is added to the local table and
the backbone gateway wants to be responsible now.

Backbone gateways which receive a CLAIM frame (and accept the backbone
gateway) must add the claim in their tables, replacing older claims if
they are present (even their own).

UNCLAIM frames
~~~~~~~~~~~~~~

::

      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet DST: FF:FF:FF:FF:FF:FF                            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet DST (cont)        |  Ethernet Source: orig addr   |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet SRC (originator addr, cont)                       |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet type: 08 06       |  HW type: 00 01               |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Protocol type: 08 00       |  HW size: 06  | Prot size: 04 |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Opcode: 02 = Reply         |  Sender HW addr: client addr  |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Sender HW addr: client addr (cont)                         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Sender IP: 0.0.0.0                                         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target HW addr: FF:43:05:01:XX:XX                          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target HW addr (cont)      | Target IP: 0.0.0.0            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target IP: 0.0.0.0 (cont)  | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

An UNCLAIM frame is sent when the backbone gateway is not responsible
anymore, e.g. due to detected roaming into the backbone or a timeout

Backbone gateways which receive an UNCLAIM frame (and accept the
backbone gateway) must remove the the claim from their tables.

ANNOUNCE frames
~~~~~~~~~~~~~~~

::

    0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet DST: FF:FF:FF:FF:FF:FF                            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet DST (cont)        |  Ethernet Source: orig addr   |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet SRC (originator addr, cont)                       |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet type: 08 06       |  HW type: 00 01               |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Protocol type: 08 00       |  HW size: 06  | Prot size: 04 |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Opcode: 02 = Reply         |  Sender HW addr: ...          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Sender HW addr: 43:05:43:05:YY:YY (cont)                   |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Sender IP: 0.0.0.0                                         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target HW addr: FF:43:05:02:XX:XX                          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target HW addr (cont)      | Target IP: 0.0.0.0            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target IP: 0.0.0.0 (cont)  | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

The periodic ANNOUNCE frames (default: every 10 seconds) by the backbone
gateways serve the following purposes:

* backbone gateways learn about the existence of other backbone
  gateways (this is important for new gateways)
* when no ANNOUNCE frames are received anymore, we can assume that
  this backbone gateway is no longer serving the backbone and can remove
  its claims
* It contains a checksum (the last 2 bytes YY:YY within the Sender HW
  address) which other backbone gateways can use to check their table
  consistency. If a table is not consistent, a backbone gateway can ask
  for the full claim table via the REQUEST frame.

Note: the SRC HW address is a "locally administered address" group
address which should not be used by any NIC or protocol, but is not
registered with the IEEE

REQUEST frame
~~~~~~~~~~~~~

::

      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet DST: Gateways addr                                |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet DST (cont)        |  Ethernet Source: orig addr   |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet SRC (originator addr, cont)                       |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet type: 08 06       |  HW type: 00 01               |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Protocol type: 08 00       |  HW size: 06  | Prot size: 04 |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Opcode: 02 = Reply         |  Sender HW addr: gw addr      |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Sender HW addr: gateway addr (cont)                        |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Sender IP: 0.0.0.0                                         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target HW addr: FF:43:05:03:XX:XX                          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target HW addr (cont)      | Target IP: 0.0.0.0            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target IP: 0.0.0.0 (cont)  | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

A REQUEST frame is sent by a backbone gateway who just received an
ANNOUNCE frames and discovers that the CRC is out of sync.

It then sends a REQUEST frame to the backbone gateway it just received
the ANNOUNCE frame from, and deletes all claims it knows from this
backbone gateway.

The asked backbone gateway will send all of its local CLAIM frames
again, and send another ANNOUNCE frame afterwards.

The requesting backbone gateway will add all claims it receives
through the CLAIM frames, and can check the CRC once more as soon as
it receives the final ANNOUNCE frame.
(If the CRC is still wrong, the process will start again)

While a request is in flight, the requesting backbone gateway will close
down its mesh-interface for broadcast to avoid loops in this period.

LOOP DETECT frame
~~~~~~~~~~~~~~~~~

::

     0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet DST: FF:FF:FF:FF:FF:FF                            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet DST (cont)        |  Ethernet Source: orig addr   |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet SRC (originator addr, cont)                       |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Ethernet type: 08 06       |  HW type: 00 01               |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Protocol type: 08 00       |  HW size: 06  | Prot size: 04 |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Opcode: 02 = Reply         |  Sender HW addr: orig addr    |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Sender HW addr: originator addr (cont)                     |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Sender IP: 0.0.0.0                                         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target HW addr: FF:43:05:05:XX:XX                          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target HW addr (cont)      | Target IP: 0.0.0.0            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |    Target IP: 0.0.0.0 (cont)  | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

A LOOP DETECT frame is sent every 60 seconds to detect loop scenarios
which can't be avoided by BLA-II (see
:ref:`Bridge-loop-avoidance-II#Limitations <batman-adv-Bridge-loop-avoidance-II-Limitations>`).

The Ethernet source MAC address has the first two octets set to BA:BE,
and the following octets are randomized and changed with every sent
packet. The packet will be sent to LAN first, and in contrast to other
packet types, other nodes will be forwarded into the mesh. If a LOOP
DETECT packet is received from the mesh (which is only processed if the
sending originator is not in the same BLA group), and the randomized
Ethernet Source MAC matches the own one, an event is thrown. This can be
handled by userspace to react to the loop scenario, e.g. by disabling
interfaces.

group forming
~~~~~~~~~~~~~

Within the "Target HW address", the last 2 bytes XX:XX are used for as a
local group identifier.

After starting batman, these bytes are initialized with the CRC16
checksum of the local mac address. Once it receives a claim frame from
another backbone gateway which is also known through the mesh, the own
group identifier is copied from this other backbone gateway when it is
bigger than the own one. Due to this mechanism, after a short period all
mesh nodes who are participating in the same mesh share the same group
id.

Generally, claim frames are only accepted if they are on the same group
(e.g. participating on the same mesh). This helps for some network
scenarios, e.g. when multiple different meshes are connected to one
shared backbone (see two meshes test setup below).

.. |image0| image:: claimtypes.svg

