.. SPDX-License-Identifier: GPL-2.0

batmand (legacy)
================

batmand was the first implementation of the B.A.T.M.A.N. routing
protocol. It is a user space daemon which operates on layer 3 (IP layer)
by altering the routing table.

.. note::

   batmand has not been developed further for a couple of years, but is
   still actively used by a few projects. Most of the active development
   today is performed on :doc:`batman-adv </batman-adv/index>`.

The `manpage <https://downloads.open-mesh.org/batman/manpages/batmand.8.html>`__
describes all options of batmand.

Getting started
---------------

:doc:`BATMAN_Daemon_HowTo`
  build, install and run batmand

:doc:`InternetTuning`
  how batmand handles internet access and what features it offers

:doc:`AnnouncingNetworks`
  announce and revoke networks (HNA) on the fly

:doc:`VisualizeMesh`
  get graphics of the mesh network

:doc:`Faq`
  frequently asked questions about batmand

.. toctree::
   :hidden:

   BATMAN_Daemon_HowTo
   InternetTuning
   AnnouncingNetworks
   VisualizeMesh
   Faq

Developer information
---------------------

:doc:`RoutingVodoo`
  the routing table manipulation of batmand

:doc:`DebugOutput`
  understand the debug output

:doc:`VisOutput`
  work with the output of the vis server

:doc:`Coredump`
  configure and retrieve coredumps after a crash

.. toctree::
   :hidden:

   RoutingVodoo
   DebugOutput
   VisOutput
   Coredump

Protocol documentation
----------------------

* :doc:`/open-mesh/BATMANConcept` - overview of B.A.T.M.A.N.'s main
  concepts
* :doc:`/open-mesh/Routing_scenarios` - routing scenarios a routing
  protocol should be able to handle
* :doc:`/open-mesh/The-olsr-story` - the roots of B.A.T.M.A.N.
  (Dec 2006)
* `CCCamp 2007 talk (video)
  <https://downloads.open-mesh.org/batman/misc/cccamp07-B.A.T.M.A.N._-_Better_Approach_to_Mobile_Ad-Hoc_Networking.m4v>`__
  - Elektra and Marek explain the batman routing algorithm and features
  of batmand (August 2007)
* `B.A.T.M.A.N. RFC draft
  <https://tools.ietf.org/html/draft-wunderlich-openmesh-manet-routing-00>`__
  - the routing algorithm used in batman 0.2
* `B.A.T.M.A.N. status
  <https://downloads.open-mesh.org/batman/papers/batman-status.pdf>`__
  - state of B.A.T.M.A.N. (June 2007)

History
-------

:doc:`Why-starting-batman`
  why OLSR was dropped in favor of a new routing protocol

:doc:`BerlinExperience`
  the first B.A.T.M.A.N. deployments in Berlin

.. toctree::
   :hidden:

   Why-starting-batman
   BerlinExperience

.. only::  subproject

   Indices
   =======

   * :ref:`genindex`
