.. SPDX-License-Identifier: GPL-2.0

=========================================
Alfred output format enhancement proposal
=========================================

Alfred's current output format is a custom one which makes it a little
more difficult to use by a program because it needs to do some manual
parsing. E.g. you cannot simply plug in your favourite json library to
load and parse the information into your code.

Here's a proposal which aims for the following three key benefits:

-  Textual information is displayable in a human readable format.
-  Information is easily usable by a program.
-  Binary data can be inserted, queried and piped on the shell.

Valid UTF8 text only by default
===============================

*Valid UTF8 text, ASCII, example 1:*

*Store:*

::

    $ cat /etc/hostname | alfred -s 64

*Read:*

::

    $ alfred -r 64
    {
        "fe:f1:00:00:01:01" : "OpenWRT-node-1\n"
    }

*Valid UTF8 text, ASCII, example 2:*

*Store:*

::

    $ echo -n "\x00" | alfred -s 64

*Read:*

::

    $ alfred -r 64
    {
        "fe:f1:00:00:01:01" : "\u0000"
    }

*Valid UTF8 text, non-ASCII:*

*Store:*

::

    $ echo -n "\xe2\x98\xae" |  alfred -s 64

*Read:*

::

    $ alfred -r 64
    {
        "fe:f1:00:00:01:01" : "☮"
    }

*On non-UTF8 data:*

Simply fail with an error return code and message, example:

*Store:*

::

    $ echo -n "\x80" | alfred -s 64
    Invalid UTF8 input! Consider using --binary

Binary mode switch
==================

*Store:*

::

    $ cat /tmp/binary/file.in | alfred -s 64 --binary

*Read:*

::

    $ alfred -r 64
    {
        "fe:f1:00:00:01:01" : "tIerwaEjNjY="
    }
    $ alfred -r 64 --binary "fe:f1:00:00:01:01" > /tmp/binary/file.out

So '$ alfred -r 64' displays the data in base64 (or some other suitable,
json string compatible format).

Namespaces
==========

*Store:*

::

    $ cat /etc/hostname | alfred -s 64 -n "hostname"
    $ echo -n "v42" | alfred -s 64 -n "version"
    $ echo -n "\xe2\x98\xae" | alfred -s 64 -n "alignment"
    $ cat /tmp/cake.pdf | alfred -s 64 -n "cake.pdf" --binary
    $ tar -cf - /etc | xz -c | alfred -s 64 -n "config-backup" --binary

*Read:*

::

    $ alfred -r 64
    {
        "fe:f1:00:00:01:01" : {
            "hostname" : "OpenWRT-node-1\n",
            "version" : "v42",
            "alignment" : "☮",
            "cake.pdf" : "VGhlIGNha2UgaXMgYSBsaWUhCg==",
            "config-backup" : "Wxj5fsra7gGLuD3VJf0aBsfmi2HEpTn+ZuAhJ0tyom1hX11vxqJDJn1q/Md+tDKUyLI="
        }
    }
    $ alfred -r 64 -n "cake.pdf" --binary "fe:f1:00:00:01:01" > /tmp/lie.txt
    $ alfred -r 64 -n "config-backup" --binary "fe:f1:00:00:01:01" | xz -dc > /tmp/etc.tar
