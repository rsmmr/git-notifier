#
# Makefile is used only for building the distribution.

VERSION   = 0.1

DISTFILES = git-notifier README COPYING

all:

dist:
	rm -rf git-notifier-$(VERSION) git-notifier-$(VERSION).tgz
	mkdir git-notifier-$(VERSION)
	cp $(DISTFILES) git-notifier-$(VERSION)
	tar czvf git-notifier-$(VERSION).tgz git-notifier-$(VERSION)
	rm -rf git-notifier-$(VERSION)
