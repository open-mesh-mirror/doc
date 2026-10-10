.. SPDX-License-Identifier: GPL-2.0

Kernel Debugging
================

The :doc:`Emulation Environment <Emulation_Environment>` documentation explains how to start
multiple virtual Linux kernels+userspace, connect them and use various
helpers to test a whole linux system. But some problems can be debugged
easier with the help of an actual debugger like GDB or by analyzing the
state of the kernel after a crash.

Live debugging with GDB
-----------------------

GDB can be attached to a running kernel using different remote stubs.
The right one depends on where the problem can be reproduced:

.. list-table::
   :header-rows: 1

   * - Method
     - Target
     - Requirements
   * - :doc:`Kernel_debugging_with_qemu's_GDB_server`
     - virtual instance
     - none (built into QEMU)
   * - :doc:`Kernel_debugging_over_JTAG`
     - real hardware
     - board exposing JTAG/SWD, debug adapter, OpenOCD
   * - :doc:`Kernel_debugging_with_kgdb`
     - real hardware
     - serial console with polling support

Useful commands and scripts for all of these methods are collected in
:doc:`GDB_Linux_snippets`.

.. toctree::
   :hidden:
   :maxdepth: 1

   Kernel_debugging_with_qemu's_GDB_server
   Kernel_debugging_over_JTAG
   Kernel_debugging_with_kgdb
   GDB_Linux_snippets

Post-mortem analysis
--------------------

When a kernel already crashed, the following methods help to collect
information for the analysis:

:doc:`Crashlog_with_pstore`
  store the kernel log (including the stack trace) of a crash in memory
  which survives a reboot

:doc:`Crashdumps_with_kexec`
  boot a crash kernel to save the complete memory of the crashed kernel
  for offline analysis

.. toctree::
   :hidden:
   :maxdepth: 1

   Crashlog_with_pstore
   Crashdumps_with_kexec
