# pam-utils

Two programs for the PAM configuration of Aeltra OS.

## pam-auth-update

Writes the files `/etc/pam.d/common-*`, which the PAM configuration of
every service includes, from profiles that packages install to
`/usr/share/pam-configs`. See `man/pam-auth-update.8`.

It is based on the program of the same name in Debian's packaging of PAM
(`debian/local/pam-auth-update`, written by Steve Langasek, Copyright
2008 Canonical Ltd.). Debian's program is written in Perl and asks its
questions with debconf. This one is a rewrite in POSIX shell and awk that
asks nothing, so that it runs on a system that has only busybox. The
formats are Debian's:

* A profile of a Debian package can be used as it is.
* The templates in `templates/` have Debian's marker lines and Debian's
  lines between them, with comments of our own.
* `profiles/unix` is Debian's profile for pam_unix, with sha512 for new
  password hashes where Debian has yescrypt (see below).
* For the same profiles and templates the same files are written, except
  that Debian's program leaves a blank at the end of a line without
  options.

What it does differently is listed in the manual page under DIFFERENCES.

## pam-securetty

Restricts logins of root to the consoles of the machine with pam_securetty,
and lifts that restriction again. See the comment at the top of the script.

## Building and installing

    make [PREFIX=/usr]
    make check
    make install [DESTDIR=...]

Nothing is compiled. The programs need a POSIX shell, awk, sed, cmp and
the usual file tools at run time.

## Password hashes

The profile `unix` tells pam_unix to hash new passwords with sha512.
Debian has yescrypt there. The `crypt` of musl cannot do yescrypt, and
Aeltra OS is built with musl and with glibc: sha512 is what both can
check, so that an /etc/shadow can be taken from one system to the other.

## Tests

`make check` runs `tests/run-tests`, which calls the program on directory
trees it makes up. Another awk or shell can be tried with

    AWK="busybox awk" TEST_SHELL="busybox sh" sh tests/run-tests

`tests/compare-with-debian` is for a Debian host. It runs Debian's
program and this one on the profiles that are installed there and
compares what they write.

## License

pam-auth-update is free software under version 3 of the GNU General
Public License, like the program it is based on, see `COPYING`. The
templates and the profile come from Debian's packaging of PAM.

pam-securetty is in the public domain.
