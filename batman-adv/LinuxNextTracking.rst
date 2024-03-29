.. SPDX-License-Identifier: GPL-2.0

Tracking the linux-next branch
==============================

We have currently our own branch to create patches for linux. These
patches are send to a sub-system maintainer which integrates them into
his own git repository. New patches from other people usually went to
linux-next. We have to create patches on top of linux-next unless they
are only small bug fixes directly for 2.6.

Other people will also create patches which may affect our code and thus
we have to import them too in our codebase. In a perfect world these
people will CC: us, but we aren't in a perfect world and we must ensure
by our self that we get informed about them. The first approach was to
check linux-next before we try to rebase our patches on top of
linux-next. This created a large gap until we noticed them or we forgot
them at all.

The new approach is to create a mirror of linux-next on our server,
install a small script which parses the commits in post-receive and send
mails when there are changes in fails inside net/batman-adv. This script
is stolen from https://git.open-mesh.org/batman-adv.git.

Initial setup
-------------

::

  su batman -
  cd $HOME
  git clone --mirror git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
  echo "LinuxNextTracking" >  linux-next.git/description
  cp /srv/git/batman-adv/hooks/post-receive linux-next.git/hooks/manual-hook
  chmod +x linux-next.git/hooks/manual-hook
  cat << 'EOF' > linux-next.git/sync-git
  #! /bin/sh
  export MY_REV="refs/heads/main"
  export GIT_DIR=/home/batman/linux-next.git
  cd "$GIT_DIR"
  cd /home/batman/linux-next.git
  oldrev="@git rev-parse $MY_REV@"
  git fetch
  newref="@git rev-parse main@"
  if [ "$oldrev" != "$newref" ]; then
      echo "$oldrev" "$newref" "$MY_REV" | ./hooks/manual-hook
  fi
  EOF
  chmod +x linux-next.git/sync-git

The script has to be modified a little bit to get it working after
refs/heads/main was modified. Just exchange

::

  git rev-parse --not --branches | grep -v $(git rev-parse $refname) | git rev-list --reverse --stdin $oldrev..$newrev -- net/batman-adv

with

::

  git rev-list --reverse $oldrev..$newrev -- net/batman-adv

The next step is to add it to batman crontab

::

  15 0   *   *   *     /home/batman/linux-next.git/sync-git >& /dev/null

To get it really to send something we have to add the mail information
to the hooks section of linux-next.git/config

::

  [hooks]
      mailinglist = my-address@foobar.com
      envelopesender = postmaster@open-mesh.org
      emailprefix = "[linux-next] "

Now the owner of my-address@foobar.com will receive our and foreign
patches which touches net/batman-adv in linux-next... each day at 0:15 (or
at least once a day).
