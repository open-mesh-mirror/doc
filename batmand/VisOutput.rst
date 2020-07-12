.. SPDX-License-Identifier: GPL-2.0

Working with the vis server output
==================================

This artcile is for those that intend to write their own visualization
tool, combine the vis output with a map or want to understand the vis
server output for another reason. If you want to setup the vis server
for the batmand have a look at this :doc:`article <VisualizeMesh>` or for
BATMAN-Advanced at :doc:` this one </batman-adv/VisAdv>`.

Here is a sample output from the vis server in the dot draw format.
Newer vis versions offer alternative formats (e.g. JSON) which follow
the same rules but use another output style.

::

   digraph topology
   {
   "5.174.37.225" -> "5.224.160.202"[label="2.13"]
   "5.174.37.225" -> "192.168.15.0/24"[label="HNA"]
   "5.174.117.226" -> "5.174.37.225"[label="5.00"]
   "5.174.117.226" -> "0.0.0.0/0.0.0.0"[label="HNA"]
   "5.224.160.202" -> "5.174.37.225"[label="1.28"]
   "5.224.160.202" -> "0.0.0.0/0.0.0.0"[label="HNA"]
   }
   </code>

Each "digraph { ... }" block contains a complete dump of the vis servers
internal database at a given time. Every line contains the IP address of
a batman node, a network it has a relation to and a label. All nodes
sending information to the vis server are listed in the first column. If
a node is missing you should check whether there is a connection
problem.

Batman to batman connection
---------------------------

::

   "5.174.37.225" -> "5.224.160.202"[label="2.13"]
   "5.224.160.202" -> "5.174.37.225"[label="1.28"]

The batman node 5.174.37.225 has a connection towards the batman node
5.224.160.202 with a link quality of "2.13" whereas the 5.224.160.202
has a link quality of "1.28" towards the 5.174.37.225. The connection is
listed twice because each node reports it individually which gives you
the option of seeing asymetric links if you want to display it.

The link quality gives information how batman evaluates this link. 1.00
means 100% link quality, 2.00 means 50, 3.00 is 33.3 and 4.00 is 25%,
etc. The number tells you how many packets you need to send in order to
get a single successful transmission.

While looking at originator tables, debug logs or other batman output
you might see different numbers. Due to performance considerations
batmand uses its own format (TQ value) to express link quality. Its max
value is 255 and goes down to 0 (float operations are quite expensive on
embedded devices). The vis server transforms the TQ value into its own
format before outputting it.

Internet gateways
-----------------

::

   "5.224.160.202" -> "0.0.0.0/0.0.0.0"[label="HNA"]

The 5.224.160.202 announces a connection to the internet:
"0.0.0.0/0.0.0.0" and the HNA label represent gateway functionality in
the output.

Announced networks
------------------

::

   "5.174.37.225" -> "192.168.15.0/24"[label="HNA"]

The 5.174.37.225 announces a connection to the 192.168.15.0/24 network
(which does not run batman). All nodes that establish a connection to
this network use the 5.174.37.225 as gateway.

Interfaces belonging to one BATMAN-Adv node
-------------------------------------------

In BATMAN-Advanced since revision 1424, the subgraphing/cluster feature
of the dot-file-format has been added to mark interfaces as belonging to
the same originator. Every originator the vis-server found has such an
additional subgraph block:

::

   subgraph "cluster_00:11:22:33:44:55" {
       "00:11:22:33:44:55" [peripheries=2]
       "01:23:45:67:89:AB"
   }

In this example the originator '00:11:22:33:44:55' has two active
interfaces, "00:11:22:33:44:55" and "01:23:45:67:89:AB". With 'fdp' from
the `graphviz-tools <http://www.graphviz.org/>`__ for instance such
interfaces inside of a subgraph would be surrounded by a box. The
cluster-prefix is a prerequisite for this tool here to describe the
relation between those interfaces and is not a label being visualized.
Additionally, the *primary* interface gets the extra attribute
'[peripheries=2]' which is the only interface known to other
BATMAN-Nodes, except to direct neighbours (with graphviz, such an
interface gets double circled).
