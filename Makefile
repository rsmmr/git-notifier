#
# Makefile is used only for building the distribution.

VERSION   = 0.1

DISTFILES = git-notifier README COPYING

WWW = $(HOME)/www/git-notifier

all:

dist:
	rm -rf git-notifier-$(VERSION) git-notifier-$(VERSION).tgz
	mkdir git-notifier-$(VERSION)
	cp $(DISTFILES) git-notifier-$(VERSION)
	tar czvf git-notifier-$(VERSION).tgz git-notifier-$(VERSION)
	rm -rf git-notifier-$(VERSION)

www: dist
	rst2html.py README >$(WWW)/index.html
	cp git-notifier-$(VERSION).tgz $(WWW)
