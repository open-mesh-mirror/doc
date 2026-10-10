.. SPDX-License-Identifier: GPL-2.0

Development tools
=================

This section collects tools and procedures which help to develop, test and
debug batman-adv (and other mesh protocols or kernel code in general).

:doc:`Emulation_Environment`
  Run multiple virtual nodes with unmodified Linux kernels and connect them
  through configurable virtual networks. This is the recommended starting
  point for testing.

:doc:`Kernel_Debugging`
  Inspect a running kernel with GDB (in a VM or on real hardware) or analyze
  crashes after they happened.

.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Contents:

   Emulation_Environment
   Kernel_Debugging

.. only::  subproject

   Indices
   =======

   * :ref:`genindex`
