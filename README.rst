.. -*- mode: rst -*-

.. |date| date::

.. Version number is filled in automatically.
.. |version| replace:: 0.5

git-notifier
============

:Version: |version|
:Home: http://www.icir.org/robin/git-notifier
:Author: Robin Sommer <robin@icir.org>
:Date: |date|

.. contents::

Introduction
------------

``git-notifier`` is a script to be used with `git
<http://www.git.org>`_ as a *post-receive* hook. Once installed, it
emails out a summary of all changes each time a user pushes an update
to the repository. Different from other similar scripts,
``git-notifier`` sends exactly one email per change, each of which
includes a complete diff of all modifications as well as the set of
branches from which the new revision can be reached. The scripts
ensure that that each change is mailed out only exactly once by
keeping a state file of already reported revisions.

``git-notifier`` integrates nicely with `gitolite
<https://github.com/sitaramc/gitolite>`_, and it also comes with a
companion script ``github-notifier`` that watches `GitHub
<github.com>`_ repositories for changes.

Here's example of a ``git-notifier`` mail::

    Subject: [git/git-notifier] master: Adding www target to Makefile. (7dc1f95)

    Repository : ssh://<removed>/git-notifier

    On branch  : master

    >---------------------------------------------------------------

    commit 7dc1f95c97275618d5bde1aaf6760cd7ff6a6ef7
    Author: Robin Sommer <robin@icir.org>
    Date:   Sun Dec 19 20:21:38 2010 -0800

        Adding www target to Makefile.

    >---------------------------------------------------------------

     Makefile |    6 ++++++
     1 files changed, 6 insertions(+), 0 deletions(-)

    diff --git a/Makefile b/Makefile
    index e184c66..9c9951b 100644
    --- a/Makefile
    +++ b/Makefile
    @@ -5,6 +5,8 @@ VERSION   = 0.1

     DISTFILES = git-notifier README COPYING

    +WWW = $(HOME)/www/git-notifier
    +
     all:

     dist:
    @@ -13,3 +15,7 @@ dist:
     	cp $(DISTFILES) git-notifier-$(VERSION)
     	tar czvf git-notifier-$(VERSION).tgz git-notifier-$(VERSION)
     	rm -rf git-notifier-$(VERSION)
    +
    +www: dist
    +	rst2html.py README >$(WWW)/index.html
    +	cp git-notifier-$(VERSION).tgz $(WWW)


In addition, ``git-notifier`` also mails updates when branches or
annotated tags are created or removed; and it furthermore mails a
revision summary if a head moves to now include commits already
reported previously (e.g., on fast-forwards).

If a commit message contains ``[nodiff]``, the generated mail will
not include a diff. If a commit message contains ``[nomail]``, no
mail will be send for that change.

Download
--------

The current release is `git-notifier 0.5
<http://www.icir.org/robin/git-notifier/git-notifier-0.5.tar.gz>`_

Not surprisingly, ``git-notifier`` is maintained in a git repository
that you clone::

    git clone git://git.icir.org/git-notifier

You can also `browse the repository
<http://git.icir.org/git-notifier.git>`_

History
-------

The `CHANGES <CHANGES>`_ file records recent updates to
``git-notifier``.

Installation
------------

The basic installation is simple: just run the script from
``hooks/post-receive``, as in::

    #!/bin/sh

    /full/path/to/git-notifier

By default, the script will send its mails to the user running the
``git-notifier`` (i.e., the one doing the update). As that's usually
not the desired recipient, an alternative email address can be
specified via command line or git options, see the ``mailinglist``
option below.

Usage
-----

``git-notifier`` supports the options below. Alternatively to
giving them on the command line, all of them can alse be set via
``git config hooks.<option>``. For example, to set a recipient
address, do ``git config hooks.mailinglist git-updates@foo.com``:

    ``--allchanges <branches>``
        Lists branches for which *all* changes made to them should be
        mailed out as straight diffs to their previous state,
        independent of whether the corresponding commit has already
        been reported in the past. For merge commits, the mails
        include the full diff (i.e., git's ``diff -m``). This might
        for example make sense for ``master`` if one wants to closely
        track any modification applied. ``<branches>`` is a list of
        command-separated names of heads to treat this way.

    ``--debug``
        Prints the mails that would normally be generated to
        standard error instead, without sending them. The output
        also includes some further debugging information, like the
        git commands being executed during operation.

        Note that in debug mode, the script still updates its state
        file, i.e., if there are changes that haven't been reported
        yet, they will only be printed, not mailed out next time. If
        you don't want that, use ``--noupdate`` as well.

    ``--diff [rev1..]rev2``
        Mails out diffs between all revisions on the first parent's
        way from ``rev1`` to ``rev2``. This option produces output
        similar to that of a head moving forward which is listed
        with ``--allchanges``. If ``rev1`` is skipped, ``rev2~1`` is
        assumed.

        This option is primarily for debugging and retropective
        (re-)generation of this outut, and does not change the
        current notifier state in any way. The main difference to
        ``--manual`` is that it considers only revision on the first
        parent's path, and mails out actual diffs between these.

    ``--emailprefix``
        Specifies a prefix for the mails' subject line. If the prefix
        contain an ``%r``, that will be replace with the repositories
        name. Default is ``[git/%r]``. Note that the name of this
        option is compatible with some of other git notification
        scripts.

    ``--hostname <name>``
        Defines the hostname to use when building the repository
        path shown in the notification mails. Default is the
        canonical name of the system the script is running on.

    ``--ignoreremotes``
        If given, ``git-notifier`` will not report any commits that
        are already known by any configured remote repository. 

    ``--link <url>``
        Specifies a URL that will be included into notification mails
        for locating a changeset online. The URL can contain a "%s"
        placeholder that will be replaced with the corresponding git
        revision number. The URL can also contain an "%r" placeholder that
        will be replaced with the name of the repository.

    ``--log <file>``
        Write logging information into the given file. Default is
        ``git-notifier.log`` inside the repository.

    ``--mailinglist <address>``
        Specifies the recipient for all generated mails. Default is
        mailing to the system account that is running the script.

    ``--mailsubjectlen <max>`` Limits subjects of generated mails to
        ``<max>`` characters. Default os no limit.

    ``--manual [rev1..]rev2``
        Mails out notifications for all revisions on the way from
        ``rev1`` to ``rev2``. If ``rev1`` is skipped, ``rev2~1`` is
        assumed.

        This option is primarily for debugging and retropective
        (re-)generation of this output, and does not change the
        current notifier state in any way.

    ``--mergediffs <branches>``
        Lists branches for which merges should include the full diff,
        including all changes that are already part of branch commits.
        ``<branches>`` is a list of command-separated names of heads
        to treat this way.

    ``--maxdiffsize <size in KB>``
        Limits the size of mails by giving a maximum number of bytes
        that a diff may have. If the diff for a change is larger
        than this value, a notification mail is still send out but
        the diff is excluded (and replaced with a note saying so).
        Default is 50K.

    ``--noupdate``
        Does not update the internal state file, meaning that any
        updates will be reported *again* next time the script is
        run.

    ``--replyto <email>``
        Adds a ``Reply-To: <email>`` header to outgoing mails.

    ``--sender <address>``
        Defines the sender address for all generated mails. Default
        is the user doing the update (if gitolite is used, that's
        the gitolite acccount doing the push, not the system account
        running ``git-notifier``.)

    ``--updateonly``
        Does not send out any mail notifications but still updates
        the index. In other words, all recent changes will be marked
        as "seen", without reporting them.

    ``--users <file>``
        This is only for installations using gitolite <XXX>, for
        which the default sender address for all mails would
        normally be the gitolite user account name of the person
        doing the push. With this option, one can alternatively
        specify a file that maps such account names to alternative
        addresses, which will then be used as the sender for mails.

        The file must consist of line of the form ``<gitolite-user>
        <sender>``, where sender will be used for the mails and can
        include spaces. Empty lines and lines starting with ``#``
        are ignored. It's ok if for a user no entry is found, in
        which case the default value will be used.

        For example, if there's a gitolite user account "joe", one
        could provide a ``users`` file like this::

            joe    Joe Smith <joe@foo.bar>

        Now all mails triggered by Joe will have the specified
        sender.

        Note that even if ``--users`` is not given, ``git-notifier``
        will still look for such a file in ``../conf/sender.cfg``',
        relative to the top-level repository directory. In other
        words, you can check a file ``sender.cfg`` containing the
        mappings into gitolite's ``config/`` directory and it should
        Just Work.

Monitoring GitHub
-----------------

The ``git-notifier`` distribution comes with a companion script,
``github-notifier``, that watches GitHub repositories for changes. The
script maintains a local mirror of repositories you want to watch and
runs ``git-notifier`` locally on those to generate the notification
mails.

To setup ``github-notifier`` you create a configuration file
``github-notifier.cfg`` in the directory where you want to keep the
clones. ``github-notifier.cfg`` is an "ini-style" file consisting of
one or more sections, each of which defines a set of repositories to
monitor.

Here's an example set that watches just a single repository at
``github.com/bro/time-machine``::

    [TimeMachine]
    repositories=bro/time-machine
    notifier-mailinglist=foo@bar.com

This defines a set called ``TimeMachine`` consisting of just the one
GitHub repository, sending notifications to the given email address.
With this saved in the current directory as ``github-notifier.cfg``,
you can then run ``github-notifier`` and it will create a complete
clone of the remote on its first run (and not send any mails yet). On
subsequent executions, the script will update the clone and spawn
``git-notifier`` to email out notifications. For now, the best way to
automate this is to run ``github-notifier`` from ``cron``.

Note: In the future we might add a daemon mode to ``github-notifier``
that keeps it running in the background, polling for updates
regularly. Potentially it could even be triggered by a `GitHub web
hook <https://help.github.com/articles/post-receive-hooks>`_

In the following we discuss more details of the configuration file.

Specifying Repositories
^^^^^^^^^^^^^^^^^^^^^^^

The ``repositories`` entry takes a list of command-separated
repositories to monitor. Each repository has the form
``<user>/<repo>``, where ``<user>`` is a GitHub user (or organization)
and ``<repo>`` is a repository that the user (or organization)
maintains. ``<repo>`` can be the wildcard ``*`` to monitor *all* of a
user's repositories (e.g., ``repositories=bro/*``). One can exclude
individual repositories by prefixing them with a dash (e.g.,
``repositories=bro/*,-bro/time-machine``).

Authentication
^^^^^^^^^^^^^^

By default, ``github-notifier`` only monitors public repositories. You
can however also watch private ones if you provide it with suitable
credentials using the ``user`` and ``token`` options::

    user=foo
    token=3238753465abc7634657zefg

The ``token`` shouldn't be the user's password but a "personal access
token" as you can generate it in the user's account settings.

Setting Notifier Options
^^^^^^^^^^^^^^^^^^^^^^^^

Within a set one can specify any of the standard ``git-notifier``
options by prefixing them with ``notifier-``. The
``notifier-mailinglist`` options above is an example. To, e.g., set a
Reply-To header, you would use ``notifier-replyto=somebody@else.net``.

Usage
^^^^^

``github-notifier`` supports the following options:

    ``--config <file>``
        Specifies an alternative configuration file.

    ``--debug``
        Runs the script in debug mode, which means that it will (1)
        log more verbosely and to stderr, and (2) run ``git-notifier``
        with the ``--debug`` and ``--noupdate`` options.

License
-------

``git-notifier`` comes with a BSD-style licence.
