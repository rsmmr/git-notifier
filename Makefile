#
# Makefile is used only for building the distribution.

VERSION   = 0.1

DISTFILES = git-notifier README COPYING

WWW = $(HOME)/www/git-notifier

all:

dist:
	rm -rf git-notifier-$(VERSION) git-notifier-$(VERSION).tar.gz
	mkdir git-notifier-$(VERSION)
	cp $(DISTFILES) git-notifier-$(VERSION)
	tar czvf git-notifier-$(VERSION).tar.gz git-notifier-$(VERSION)
	rm -rf git-notifier-$(VERSION)

www: dist
	rst2html.py README >$(WWW)/index.html
	cp git-notifier-$(VERSION).tar.gz $(WWW)
