.. SPDX-License-Identifier: GPL-2.0

TVLV
====

This document describes in detail the TVLV format, the TVLV API and
contains a list of TVLV definitions for reference. Be sure to have read
the `TVLV introduction <https://www.open-mesh.org/news/44>`__ if you don't understand the scope of this document.

TVLV format
-----------

A typical TVLV container is composed of the following fields:

-  TVLV type: TVLV type identifying the content of value (see below for
   the list of types)
-  Version: version number of the TVLV type
-  Length: length of the value field in bytes
-  Value: the actual data of this TVLV

Certain TVLV containers have no payload at all (with a the length field
set to zero and no value field) which can be used to let the mesh know
about a feature's availability.

TVLV
~~~~

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |   TVLV Type   |    Version    |             Length            | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                             Value 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

TVLV API
--------

OGM TVLV transmission
~~~~~~~~~~~~~~~~~~~~~

To periodically transmit a TVLV container with every Originator Message
(OGM) an container\_register() call has to be performed. The function
takes the TVLV type, version, length and value as argument and
internally stores this information. The aforementioned length handling,
the periodic scheduling, etc happens transparently to the caller. The
container\_register() call also takes care of updates to an existing
TVLV type + version container.

::

    void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
                                        uint8_t type, uint8_t version,
                                        void *tvlv_value, uint16_t tvlv_value_len);

To stop transmitting a TVLV type + version container the
container\_unregister() function has to be invoked.

::

    void batadv_tvlv_container_unregister(struct batadv_priv *bat_priv,
                                          uint8_t type, uint8_t version);

Unicast TVLV transmission
~~~~~~~~~~~~~~~~~~~~~~~~~

The API allows to send TVLVs directly to originators in the network
(instead of broadcasting the TVLVs with each OGM). The function follows
the container register semantics except for requiring a source and
destination mac address:

::

    void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, uint8_t *src,
                                  uint8_t *dst, uint8_t type, uint8_t version,
                                  void *tvlv_value, uint16_t tvlv_value_len);

Handle incoming TVLVs
~~~~~~~~~~~~~~~~~~~~~

The TVLV API processes incoming packets and parses their TVLV
containers. If a TVLV container is found and a handler function was
installed for this specific TVLV type, the handler is called with the
TVLV data as argument along with a couple of other useful values. To
install such a handler the handler\_register() function has to be
called:

::

    void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
                                      void (*optr)(struct batadv_priv *bat_priv,
                                                   struct batadv_orig_node *orig,
                                                   uint8_t flags,
                                                   void *tvlv_value,
                                                   uint16_t tvlv_value_len),
                                      int (*uptr)(struct batadv_priv *bat_priv,
                                                  uint8_t *src, uint8_t *dst,
                                                  void *tvlv_value,
                                                  uint16_t tvlv_value_len),
                                      uint8_t type, uint8_t version, uint8_t flags);

TVLVs can be received through OGM packets and/or unicast TVLV packets. A
callback handler for both TVLV types can be registered.

To remove a handler a handler\_unregister() is provided:

::

    void batadv_tvlv_handler_unregister(struct batadv_priv *bat_priv,
                                        uint8_t type, uint8_t version);

Upon registering a handler it is possible to pass a couple of flags to
tweak the handler API behavior. For instance, some features need to be
also called if a certain TVLV container was not found in an OGM to learn
when the peer node has switched it off. The following flags are
available:

Handler register flags:

* BATADV\_TVLV\_HANDLER\_OGM\_CIFNOTFND: If the TVLV type has not been
  found, call this handler anyway when the OGM parsing has been completed.
  In this case the length argument will be 0 and the value will be NULL
  and a flag to indicate this condition will be passed.

Flags passed to the handler by the TVLV API:

* BATADV\_TVLV\_HANDLER\_OGM\_CIFNOTFND: Signals the handler whether
  the TVLV container has been found or whether the call was invoked due to
  the BATADV\_TVLV\_HANDLER\_OGM\_CIFNOTFND flag.

TVLV definitions
----------------

.. _batman-adv-tvlv-gateway-announcement:

Gateway announcement
~~~~~~~~~~~~~~~~~~~~

* tvlv type: 0x01
* function: Each batman-adv gateway server announces it's available
  internet connection speed, so that batman-adv gateway clients can
  select their preferable server.
* purpose: Every node keeps a list of batman-adv gateways in the mesh
  to later the preferred gateway.
* length: 8 byte gateway bandwidth information
* Fixed TVLV fields:

  - gateway bandwidth down: announced gateway download bandwidth in
    MBit/s/10 (4Bytes)
  - gateway bandwidth up: announced gateway upload bandwidth in
    MBit/s/10 (4Bytes)

* definition:

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |   TVLV 0x01   |    Version    |             Length            | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                   gateway bandwidth down                      |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                    gateway bandwidth up                       |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

DAT (Distributed ARP Table)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

* tvlv type: 0x02
* function: D.A.T. is a DHT based global ARP cache.
* purpose: the DAT component will only query other DAT-enabled nodes
* length: 0 (This is a boolean telling that this node caches ARP
  requests / replies for the mesh.)
* definition:

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |   TVLV 0x02   |    Version    |             Length            | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Network coding (also known as catwoman)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* tvlv type: 0x03
* function: Save packet transmissions & air time by combining
  packets.
* purpose: Network coding only works with other network coding
  enabled nodes.
* length: 0 byte (This is a boolean telling that this node knows how
  to decode nc-packets.)
* definition:

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |   TVLV 0x03   |    Version    |             Length            | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

.. _batman-adv-tvlv-translation-table-messages:

Translation table messages
~~~~~~~~~~~~~~~~~~~~~~~~~~

* tvlv type: 0x04
* function: Local non-mesh clients advertisement mechanism. This
  particular component needs some parameters that are propagated by the
  OGM.
* purpose: Exchange of translation table state information.
* length: variable. It is equal to the size of the fixed TVLV field +
  the size of the TT VLAN headers + the size of the TT client change
  entries.
* Fixed TVLV fields:

  - flags: translation table flags (1Byte)
  - ttvn: translation table version number (1Byte)
  - num\_vlan: number of TT VLAN data structures inside the tvlv
    container (2Bytes)

* Each TT VLAN data structure contains:

  - crc: crc32 checksum of the local translation (sub-)table
    containing entries belonging to this VLAN only (4Bytes)
  - vid: the identifier of this VLAN (2Bytes)
  - reserved: not used. Defined for alignment purposes (2Bytes)

* Each TT client change (one per announced client) contains:

  - flags: flags associated with this client
  - reserved: not used. Defined for alignment purposes (3Bytes)
  - addr: mac address of the announced client
  - vid: identifier of the VLAN where this client is connected to

* layout:

::

    ....

* definition:

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |   TVLV 0x04   |    Version    |             Length            | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |   TT Flags    |     TTVN      |       Number of VLANs         |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                        CRC32_vlan1                            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |       VID_vlan1               |       reserved_vlan1          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                        CRC32_vlan2                            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |       VID_vlan2               |       reserved_vlan2          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                       ...................                     |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                        CRC32_vlanN                            |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |       VID_vlanN               |       reserved_vlanN          |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     | flags_change1 |          reserved_change1                     |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                       mac_addr_change1...                     |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |     ...mac_addr_change1       |          vid_change1          |  
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     | flags_change2 |          reserved_change2                     |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                       mac_addr_change2...                     |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |     ...mac_addr_change2       |          vid_change2          |  
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                       ...................                     |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     | flags_changeM |          reserved_changeM                     |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                       mac_addr_changeM...                     |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |     ...mac_addr_changeM       |          vid_changeM          |  
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

.. _batman-adv-tvlv-roaming-advertisement-message:

Roaming Advertisement message
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* tvlv type: 0x05
* function: Reduce a non-mesh client's packet loss when it roams from
  one AP to the next.
* purpose: Inform the old AP about the new location of the non-mesh
  client.
* length: 8 bytes non-mesh client information
* Fixed TVLV fields:

  - client mac address: mac address of the roaming non-mesh client (6
    bytes)
  - vid: vlan tag id of the roaming non-mesh client (2 bytes)

* definition:

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |   TVLV 0x05   |    Version    |             Length            | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |                       Client mac address                      |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |      Client mac address       |              VID              |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Multicast capability
~~~~~~~~~~~~~~~~~~~~

* tvlv type: 0x06
* function: Reduces the airtime consumed by multicast packets, e.g.
  by using multicast awareness to decide whether a frame can be sent via
  unicast or dropped.
* purpose: Lets other nodes know whether an originator is capable of
  announcing its multicast listeners via the translation table. The
  flags further inform other nodes about whether an originator needs to
  receive all multicast traffic of a certain type.
* length: 4 bytes (1 byte flag information)
* Fixed TVLV fields:

  - flags: multicast flags announced by the orig node (1 byte), see
    :doc:`the multicast flags page <Multicast-optimizations-flags>` for
    details
  - reserved: not used. Defined for alignment purposes (3 bytes)

* definition:

::

     0                   1                   2                   3
     0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |   TVLV 0x06   |    Version    |             Length            | 
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |     flags     |                    reserved                   |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
