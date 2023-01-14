.. SPDX-License-Identifier: GPL-2.0

Using the batman git repositories
=================================

If you want to find out why we also have a git repository now, please
read `here <https://www.open-mesh.org/news/6>`__.

Clone
-----

To retrieve the latest changes you can pull from the read-only http
frontend.

::

  git clone https://git.open-mesh.org/batman-adv.git batman-adv

There is also a repository for kernel integration. You are about to
download 2GB of sources - that may take a while!

::

  git clone https://git.open-mesh.org/linux-merge.git -b batadv/net-next

Branches
--------

The main git repository is divided into several branches to make working
easier.

main branch
~~~~~~~~~~~

The main branch will have all upcoming changes. Bugfixes are merged
from stable to main.

stable branch
~~~~~~~~~~~~~

The stable only gathers bug fixes for the last release.

Create branch associated with the remote-tracking branch after cloning
the repository

::

  git switch -c stable --track origin/stable

Cherry-picking a commit from main branch

::

   git switch stable
   git cherry-pick $SHA1

Linux integration
~~~~~~~~~~~~~~~~~

The linux-merge repository is a clone of netdev's net-next tree.
With the help of some git voodoo the main branch is merged with this
branch in the folder: net/batman-adv/. If you wish to merge the latest
main branch changes into the linux branch you need to
:doc:`pull the newest changes in main from the batman-adv.git </batman-adv/SubmittingLinux>` repository.
