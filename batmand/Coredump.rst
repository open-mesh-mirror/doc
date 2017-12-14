.. SPDX-License-Identifier: GPL-2.0

What is a coredump ?
====================

A coredump is the state of the programs memory when it crashed. It
allows programmers to exactly nail down the line in the code which
caused the segfault. See https://en.wikipedia.org/wiki/Core\_dump for
more information.

Why do I need ulimit and what does it do ?
------------------------------------------

As coredumps save the programs memory on the hard disk the coredump
files can become quite large because some applications consume a lot of
memory. On embedded devices (e.g. small routers) a coredump can fill the
entire disk easily. Therefore the tool "ulimit" allows you to control
what memory size is safe to be saved on disk. A "ulimit -c 20000" saves
coredumps of up to 20MB, "ulimit -c unlimited" saves everything no
matter how big it is. You can check your systems default by running
"ulimit -c" without any value. If the setting is too small or
coredumping is disabled you have to run "ulimit -c " each time before
you start batman.

How to get a batman coredump ?
------------------------------

-  log into a shell on your device
-  set the ulimit value if necessary (see ulimit section of this
   document)
-  start batman in this very shell but don't let it fork into the
   background
   using a debug level (-d 3 or -d 4)
-  do not close the shell as it will kill the running batman
-  make batman crash (depending on the bug you experience)
-  retrieve the "core" file from the current directory

*Don't forget to send the used batman binary along with the coredump.
Without the correct binary the coredump is useless!*

I can't find the coredump ...
-----------------------------

* May be batman did not crash but just exited ? A coredump can be
  created only on a segmentation fault. Your system logs should contain a
  log entry similar to "Error - SIGSEGV received, trying to clean up ..."
  otherwise batman did not crash.
* Did you check the ulimit section ?
* The coredumping behaviour can be modified by changing some /proc
  parameters like /proc/sys/kernel/core\_uses\_pid and
  /proc/sys/kernel/core\_pattern. In most cases the defaults are the right
  choice. Only modify them if you are sure what you are doing!
* Some distributions (especially for embedded devices) use busybox
  which allows to completely disable coredumping (even if ulimit is set).
  Look for the CONFIG\_FEATURE\_INIT\_COREDUMPS option to learn more about
  it. OpenWRT allows to enable it via 'make menuconfig': Base system ->
  busybox -> Configuration -> Init Utilities -> Support dumping core for
  child processes.
* OpenWRT also may disable ELF core dumping in the kernel which you
  can activate by running "make kernel\_menuconfig" -> General setup ->
  Configure standard kernel features (for small systems) -> Enable ELF
  core dumps
