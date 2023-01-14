.. SPDX-License-Identifier: GPL-2.0

How to Contribute
=================

Thanks for using B.A.T.M.A.N.! If you have suggestions, comments, want
to tell us about your experiences or discuss problems the best thing is
always to use the :doc:`Mailing List <MailingList>` You can always contact
us via :doc:`IRC <IRC>`.

If you like this project and you want to take part and/or give something
back, here is a short list of starting points:

Reporting Bugs
--------------

If you find a bug, please see if the problem is already known in the by
Reading the Tickets:

-  for `batman-adv </projects/batman-adv/issues>`__
-  for `batctl </projects/batctl/issues>`__
-  for `alfred </projects/alfred/issues>`__
-  for `batmand </projects/batmand/issues>`__
-  for `vis </projects/vis/issues>`__

If not, please add a new Ticket:

-  for `batman-adv </projects/batman-adv/issues/new>`__
-  for `batctl </projects/batctl/issues/new>`__
-  for `alfred </projects/alfred/issues/new>`__
-  for `batmand </projects/batmand/issues/new>`__
-  for `vis </projects/vis/issues/new>`__

Please add as much information as possible. In particular interesting
are:

-  Which branch (batman, batctl, batman-adv)
-  Which version (0.X, git revision number)
-  kernel version, distribution (and version)
-  machine type (PC, Linksys WRT, Fon, NS2, ...)
-  command line parameters used
-  iptables/firewall rules
-  :doc:`get a coredump </batmand/Coredump>` if you experience a segfault
-  your guess what triggered the problem. ;)

Documentation / Feedback
------------------------

Write an article about your experience with B.A.T.M.A.N. and have it
published here or ask us to link to your site:

-  How did you find us ?
-  How does you setup look like ?
-  Where are you building your mesh ?
-  What problems did you encounter ?
-  How did you debug / solve them ?
-  What did you like / not like ?
-  How can B.A.T.M.A.N. improve ?

There's lots of people that want to know about B.A.T.M.A.N. - help us to
spread the word! You also can create a wiki account and improve the
documentation.

Research
--------

B.A.T.M.A.N. gives much room for research, especially the layer 2
implementation in the kernel. Get in touch with us to share your ideas.
If you write papers we are happy to publish them here or link to your
page. If you are looking for the right topic or mentorship feel free to
contact us. We have more ideas than time to implement them.

Development
-----------

You looked in the code ? Fixed bugs ? Added a cool new function ?
Integrated B.A.T.M.A.N. in a distribution ? Don't hesitate to let us and
others know! We can avoid duplicated work by publishing it here or
linking to your page. Patches are always welcome and can be posted on
the :doc:`mailing list <MailingList>` to get integrated. We also hand out
git access to people that want to get involved.

Submitting patches
------------------

If you intend to send us patches, please consider the following
guidelines:

* Prefer small & digestible over long "all in one" patches.
* No MIME, no links, no compression, no attachments. Just plain text
  (patches are to be sent inline).
* Patches sent to the mailing list should include "PATCH" in the
  subject to make it easier to distinguish between patches and
  discussions.
* The mail's subject will become the first line in the commit message.
  The body contains the longer patch description and the patch (unified
  format) itself. Please also specify the target branch (e.g. batctl,
  batman-adv, etc) at the beginning of the subject line.
* Add a "Signed-off-by: Your Name <you@example.com>" line to the patch
  message to make the ownership of the patch clear.
* Patches for B.A.T.M.A.N. Advanced need to follow the linux kernel
  coding style closely (use checkpatch.pl to verify your patch) as well as
  the linux "how to submit patches" guidelines (search for the term
  SubmitPatches to find thorough documentation).
* Check it using static analysis tools like
  `sparse <https://sparse.wiki.kernel.org/>`__ (cgcc) and
  `cppcheck <http://cppcheck.sourceforge.net/>`__
* Patches against the batman-adv main branch must be formatted using

::

    git format-patch $BASECOMMIT

-  README, manpage and sysfs-class-net-\* must be updated together with
   the related source change
-  Add or update kerneldoc to functions and structures you add or
   modify.
-  batman-adv changes affecting batctl have to be send with the batctl
   patches in the same patchset
-  it is recommended to use \`git send-email\` to send the mails to the
   mailinglist
-  An exemplary good submission you may want to look at can be found
   here:
   https://patchwork.open-mesh.org/project/b.a.t.m.a.n./patch/1261051915-13960-1-git-send-email-sven.eckelmann@gmx.de/
