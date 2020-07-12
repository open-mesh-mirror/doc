.. SPDX-License-Identifier: GPL-2.0

Using the batman git repositories
=================================

If you want to find out why we also have a git repository now, please
read `here <https://www.open-mesh.org/news/6>`__.

Checkout
--------

To retrieve the latest changes you can pull from the read-only http
frontend.

::

  git clone https://git.open-mesh.org/batman-adv.git batman-adv

There is also a repository for kernel integration. You are about to
download 300MB of sources - that may take a while!

::

  git clone https://git.open-mesh.org/linux-merge.git -b batadv/net-next

Branches
--------

The main git repository is divided into several branches to make working
easier.

master branch
~~~~~~~~~~~~~

The master branch will have all upcoming changes. Bugfixes are merged
from maint to master.

maint branch
~~~~~~~~~~~~

The maint only gathers bug fixes for the last release.

Create branch associated with the remote-tracking branch after cloning
the repository

::

  git checkout -b maint --track origin/maint

Cherry-picking a commit from master branch

::

   git checkout maint
   git cherry-pick $SHA1

Linux integration
~~~~~~~~~~~~~~~~~

The linux-merge repository is a clone of David Miller's net-next tree.
With the help of some git voodoo the master branch is merged with this
branch in the folder: net/batman-adv/. If you wish to merge the latest
master branch changes into the linux branch you need to
:doc:`pull the newest changes in master from the batman-adv.git </batman-adv/SubmittingLinux>` repository.
