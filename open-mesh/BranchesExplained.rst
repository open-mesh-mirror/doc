.. SPDX-License-Identifier: GPL-2.0

Branches Explained
==================

The batman project that started with a basic protocol and a single
userspace routing daemon, attracted quite some attention over the years
which led to many new ideas and concepts meant to improve the project.
These ideas often resulted in proof-of-concept "branches" of which some
turned out to be impractical and disappeared but others came to stay. As
a consequence different names were created to distinguish these concepts
as the name "batman" became a broader term for everything around the
project. This page aims to shed some light on all these different names
to make it easier to understand the differences.

numbers, numbers
----------------

Whenever Roman numerals (as III or IV) are mentioned they refer to the
version of B.A.T.M.A.N.'s routing algorithm and thus describe how the
routing information are flooded and how they are handled to make the
best routing decision possible.

Arabic numerals are used to distinguish the implementation's version.
Next to the routing algorithm many features and goodies are added to
simplify the users life.

Example: batmand 0.2 uses the B.A.T.M.A.N. III routing algorithm.

.. _open-mesh-branchesexplained-batmand:

batmand
-------

Historically, the first implementation of the B.A.T.M.A.N. routing
protocol was a user space daemon named batmand. Batmand operates on
layer 3 (IP layer) of the OSI model by altering the routing table and
offers everything you would expect from a standard routing daemon.
Almost all real-world implementations of mesh routing algorithms have
started on layer 3 - and most of them still work exclusively on layer 3
today. Check our :doc:`batmand doc </batmand/Doc-overview>` section if you
want to learn more about is capabilities.

Note: batmand has not been developed further for a couple of years, but
is still actively used by a few projects. Therefore, sources and
documentation are still available. Most of the active development today
is performed on batman-adv.

BMX
---

Initially, the BMX branch was used to implement and test new features
and concepts to overcome certain limitations of the routing algorithm.
It started on the code base of batmand 0.3 but, over time, developed
into a completely different direction, so that a re-integration became
impossible.
Today, it is an independent project hosted at http://www.bmx6.net.

batman-adv
----------

Early 2007 some developers started experimenting with the idea of
routing on layer 2 (Ethernet layer) instead of layer 3. As only little
knowledge about routing on this low level was available at that time, a
first prototype was developed, operating in userspace in form of a
daemon but already using layer 2. To differentiate from the layer 3
routing daemon the suffix "adv" (spoken: advanced) was chosen - the
batman-adv userspace daemon was born. It uses the routing algorithm of
batman 0.3, but instead of sending UDP packets and manipulating routing
tables, it provides a virtual network interface and transparently
transports packets on its own.

However, the virtual interface in userspace imposed a significant
overhead for low-end wireless access points which led to a
re-implementation as a kernel module. The batman-adv userspace daemon
has been removed, so today "batman-adv" refers to the kernel module
only. Currently, most of the development happens around batman-adv which
is part of the official Linux kernel since 2.6.38.

To understand the implications of routing on layer 2, the
:doc:`batman-adv page </batman-adv/Wiki>` should be a good starting point
Further documentation is available in our
:doc:`batman-adv doc </batman-adv/Doc-overview>` section.

batctl
------

As batman-adv operates in kernelland a handy tool to manage the module
and debug the network became necessary. The batctl tool was created to
fill that gap and, since then, has become a valuable companion of
batman-adv.

alfred
------

alfred is a user space daemon for distributing arbitrary local
information over the mesh/network in a decentralized fashion. This data
can be anything which appears to be useful - originally designed to
replace the batman-adv visualization (vis), you may distribute
hostnames, phone books, administration information, DNS information, the
local weather forecast ...

Alfred does not strictly require batman-adv to operate, but can use
neighborhood information from batman-adv when available. It is a nice
additional service if there are additional information to be distributed
over a mesh, but alfred is not required to run a batman-adv mesh
network.
