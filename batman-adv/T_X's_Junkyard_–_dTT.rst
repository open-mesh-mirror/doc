T X's Junkyard – distributed Translation Table
==============================================

Problem
-------

In larger mesh networks we are accumulating more and more TT entries,
leading to a significant amount of memory usage for the common, cheap
wifi routers with 32MB of RAM. The recent multicast optimization
additions probably increases this by a factor of about 4-6.

Each global TT entry currently takes ~200 bytes (144B for struct, 56B
for orig\_list\_entry). Maybe it's even more since they are allocated
from kmalloc-node (objsize 192) and kmalloc-64 kmem-caches?

Freifunk Hamburg has about 3000 clients. @256B per TT entry this means
750KB. With the multicast factor, that's ~4MB. Which is quite a lot for
32MB devices.

Solution: ''Long-Term'' + ''Short-Term'' Memory?
------------------------------------------------

DHT
~~~

Many global TT entries are never used by a node. We could use the
current TT global entry layout for frequently used entries. And push
unused entries to a distributed storage. We already have a DHT for DAT,
we could generalize it?

USB-Storage
~~~~~~~~~~~

Instead of using a DHT, we could use local storage. The flash storage of
these wifi routers is usually even smaller than the RAM. However, a few
GB large USB sticks are cheap+tiny and many wifi routers come with a USB
port these days. Storing databases on such USB devices is fast and has
no packet loss compared to remote storage. batman-adv could search for
mounted devices with a magic folder "wayne-enterprises" in their root
directory.

(for the few devices without USB, we could come up with an
"Ethernet-to-USB" converter, utilizing the USB-over-IP feature of the
Linux kernel? Would need the OS to discover and configure it, would be
ugly to do all this from batman-adv... More headaches: What to do if
storage fails or userspace messes with it? Maybe use raw devices
instead, ones which are marked as wayne-fs in the partition table?)
