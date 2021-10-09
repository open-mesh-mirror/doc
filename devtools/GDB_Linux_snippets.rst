.. SPDX-License-Identifier: GPL-2.0

GDB Linux snippets
==================

Python datastructure helper
---------------------------

It is also possible to evaluate data structures in the gdb commandline
using small python code blocks. To get for example the name of all
devices which batman-adv knows about and the name of the batman-adv
interface they belong to, just enter following in the initialized,
interrupted gdb session:

.. code-block:: python

  python
  import linux.lists
  from linux.utils import CachedType

  struct_batadv_hard_iface = CachedType('struct batadv_hard_iface').get_type().pointer()

  for node in linux.lists.list_for_each_entry(gdb.parse_and_eval("batadv_hardif_list"), struct_batadv_hard_iface, 'list'):
      hardif = node['net_dev']['name'].string()
      softif = node['soft_iface']['name'].string() if node['soft_iface'] else "none"
      gdb.write("hardif {} belongs to {}\n".format(hardif, softif))
  end

.. _devtools-gdb-linux-snippets-Working-with-external-Watchdog-over-GPIO:

Working with external Watchdog over GPIO
----------------------------------------

There are various boards which use external watchdog chips via GPIO.
They have to be triggered regularly (every minute or even more often) or
otherwise the board will just suddenly reboot. This will of course not
work when Linux is no longer in control and kgdb/gdb is the only way to
interact with the system.

But luckily, we can just write manually to the registers (every n
seconds). For example on ar71xx, we have two possible ways:

* write to the clear/set registers

  - set bit n in register ``GPIO_SET (0x1804000C)`` to set output value to
    1 for GPIO n
  - set bit n in register ``GPIO_CLEAR (0x18040010)`` to set output value
    to 0 for GPIO n

* overwrite the complete ``GPIO_OUT (0x18040008)`` register (which might
  modify more GPIO bits then required)

We will only demonstrate this here for GPIO 12 with GPIO_SET/GPIO_CLEAR.

::

  # check where iomem 018040000-180400ff is mapped to
  (gdb) print ath79_gpio_base
  $1 = (void *) 0xb8040000

  # set GPIO 12 to low
  (gdb) set {uint32_t}0xb8040010 = 0x00001000

  # set GPIO 12 to high
  (gdb) set {uint32_t}0xb804000C = 0x00001000

