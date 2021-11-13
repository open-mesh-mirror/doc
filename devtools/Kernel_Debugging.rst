.. SPDX-License-Identifier: GPL-2.0

Kernel Debugging
================

The :doc:`Emulation Environment <Emulation_Environment>` documentation explains how to start
multiple virtual Linux kernels+userspace, connect them and use various
helpers to test a whole linux system. But some problems can be debugged
easier with the help of an actual debugger like GDB. Information about

GDB remote stubs
----------------

.. toctree::
   :maxdepth: 1

   Kernel_debugging_with_qemu's_GDB_server
   Kernel_debugging_with_kgdb
   Kernel_debugging_over_JTAG

Various
-------

.. toctree::
   :maxdepth: 1

   GDB_Linux_snippets
   Crashlog_with_pstore
   Crashdumps_with_kexec
