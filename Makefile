VERSION = 1.0.1

PREFIX = /usr
SBINDIR = $(PREFIX)/sbin
DATADIR = $(PREFIX)/share
MANDIR = $(DATADIR)/man
DESTDIR =

TEMPLATES = \
	templates/common-account \
	templates/common-auth \
	templates/common-password \
	templates/common-session \
	templates/common-session-noninteractive

.PHONY: all check install clean dist

all: pam-auth-update

pam-auth-update: pam-auth-update.in Makefile
	sed -e 's|@DATADIR@|$(DATADIR)|g' -e 's|@VERSION@|$(VERSION)|g' \
		pam-auth-update.in > pam-auth-update
	chmod 0755 pam-auth-update

check: all
	sh tests/run-tests

install: all
	install -d -m 0755 $(DESTDIR)$(SBINDIR)
	install -d -m 0755 $(DESTDIR)$(DATADIR)/pam
	install -d -m 0755 $(DESTDIR)$(DATADIR)/pam-configs
	install -d -m 0755 $(DESTDIR)$(MANDIR)/man8
	install -m 0755 pam-auth-update $(DESTDIR)$(SBINDIR)/
	install -m 0755 pam-securetty $(DESTDIR)$(SBINDIR)/
	install -m 0644 $(TEMPLATES) $(DESTDIR)$(DATADIR)/pam/
	install -m 0644 profiles/unix $(DESTDIR)$(DATADIR)/pam-configs/
	install -m 0644 man/pam-auth-update.8 $(DESTDIR)$(MANDIR)/man8/

clean:
	rm -f pam-auth-update

dist:
	git archive --prefix=pam-utils-$(VERSION)/ \
		-o pam-utils-$(VERSION).tar.gz HEAD
