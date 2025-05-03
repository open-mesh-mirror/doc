.. SPDX-License-Identifier: GPL-2.0

Bandwidth meter
===============

This page is about a general overview of the Bandwith Meter tool in
B.A.T.M.A.N.-Advanced.
This project was started by Edo Monticelli during the 2012 Google
Summer Of Code and it is possible to read the final report
`here <https://www.open-mesh.org/news/45>`__.
Since then, the project evolved a lot and the protocol used by it
moved from a naïve Go-Back-N to the more sophisticated TCP NewReno.

The main goal of the Bandwidth Meter is to measure the maximum reachable
throughput in a TCP-like connection between two generic nodes in the
network.

The bandwidth meter protocol
----------------------------

The goal of the protocol is to approximate the behavior of TCP in
order to measure a bandwidth close to what a common TCP connection
would achieve.
The bandwidth meter protocol is the implementation of TCP using
NewReno as congestion handling mechanism.

Since the implementations of the bandwidth meter tries to reflect the
TCP one, more details can directly be found in the following documents:

* `RFC 5681 <https://tools.ietf.org/html/rfc5681>`__ (TCP)
* `RFC 6582 <https://tools.ietf.org/html/rfc6582>`__ (NewReno
  extension)
* `RFC 6298 <https://tools.ietf.org/html/rfc6298>`__ (Retransmission
  Timeout computation)

During the test batman-adv sends ICMP packets only. For this purpose a
new ICMP packet type has been created: the BW.
Received BW packets are directly passed to the bandwitdh meter
submodule which is in charge of handling the test. It has two
subtypes:

-  MSG
-  ACK

Since the test is performed unidirectionally, ACKs are not piggybacked
on normal messages (like TCP does) and therefore two different packet
types are used.
A node can participate in different tests at the same time, but with
different end-points. This means that two or more tests cannot be
performed at the same time between the same pair of nodes.

How to run a test
-----------------

The bandwidth meter is controlled by using batctl. For this purpose a
the new **bw** command has been added.
It is possible to start a test by issuing the following command:

::

  # batctl bw -t 10000 <originator address>

where **-t 10000** is an option telling batman-adv how much
*milliseconds* the test should last.
While the test is running it is also possible to interrupt it by
pressing *CTRL+C*: batctl will send a message to batman-adv and tell
it to terminate the test. batctl will then print the throughput
obtained so far.

Between two consecutive experiments at least two seconds must be waited,
to ensure the connection on the receiver side has been properly closed.

Source code
-----------

batman-adv featuring the Bandwidth meter can be found at the main
batman-adv git repository as "tp\_meter."
