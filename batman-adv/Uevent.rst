.. SPDX-License-Identifier: GPL-2.0

Uevent
======

B.A.T.M.A.N.-Advanced can throw uevents (asynchronous signals sent by
the kernel to the user space) to inform the user space about certain
events happening in the mesh. User space applications can listen to
these messages and take action depending on the event, thus allowing a
tight interaction between the kernel mesh and all sorts of applications.

How to capture uevents ?
------------------------

Various tools exist which allow to capture events generated by the
kernel, for example udev, udev\_adm or hotplug. These tools listen to
all incoming uevents and often offer a scriptable interface to parse the
messages. A batman-adv generated event could look like this:

::

    ACTION = change
    DEVPATH = /devices/virtual/net/bat0
    DEVICENAME = bat0
    SUBSYSTEM = net
    BATTYPE = gw
    BATACTION = del
    INTERFACE = bat0
    IFINDEX = 6
    SEQNUM = 613

Each event comes with an automatically created sequence number (SEQNUM).
The batman-adv module always sets the ACTION parameter to "change" and
the SUBSYSTEM to "net". DEVPATH, DEVICENAME, INTERFACE and IFINDEX point
to the corresponding batX interface. Next to these standard uevent
values which are part of every uevent message, batman-adv adds its own
parameters with the prefix "BAT". Details regarding these parameters can
be found below.

Gateway uevents
---------------

Available since: batman-adv 2011.3.0

When a batman-adv node is in gateway client mode (searching for gateway
servers - check :doc:`the gateway documentation <Gateways>` for thorough
explanations) it will inform the user space about its gateway mode state
changes: Sending an "add message" when the first gateway is chosen, a
"change message" when a better gateway was found and a "delete message"
when the currently selected gateway vanished and no alternative was
available.

In detail:

-  BATTYPE: Always set to "GW" for gateway related messages.
-  BATACTION: Set to "ADD", "CHANGE" or "DEL".
-  BATDATA: When BATACTION is set to ADD or CHANGE it contains the mac
   address of the selected gateway otherwise the parameter is not sent.

A script running in user space could start a dhcp client as soon as an
"add message" comes in and make the dhcp client request a new IP address
when a "change message" is received to ensure it always uses the
currently selected batman-adv gateway.

How to add my own uevents to batman-adv ?
-----------------------------------------

The code contains a function to make adding new uevents as easy as
possible.

Function prototype:

::

    int throw_uevent(struct bat_priv *bat_priv, enum uev_type type, 
                     enum uev_action action, const char *data);

Arguments explained:

-  bat\_priv: The pointer to the mesh-interface structure holding all
   relevant batX information.
-  type: Is the class the uevent belongs to (seen as BATTYPE in user
   space).
-  action: Defines the event's action (seen as BATACTION in user space).
-  data: Any meaningful payload that need to be sent to the userspace.

Example:

-  type: GW
-  action: ADD/CHANGE/DEL
-  data: the gateway MAC address
