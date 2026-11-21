# AGENTS.md

This file provides guidance to coding agents when working with code in
this repository.

## Project Overview

Two programs for the PAM configuration of Aeltra OS. See `README.md` for
what they are for and `man/pam-auth-update.8` for the behaviour of
pam-auth-update in detail.

* `pam-auth-update` writes `/etc/pam.d/common-*` from the profiles in
  `/usr/share/pam-configs`. It is a rewrite in shell and awk of the Perl
  program of the same name in Debian's packaging of PAM
  (`debian/local/pam-auth-update`).
* `pam-securetty` restricts logins of root to the consoles of the machine.
  It is our own and does not use pam-auth-update.

What these programs write decides who can log in. A mistake can lock
everybody out or let everybody in, so a change is not done before the
tests pass and a test for it has been added.

## Layout

* `pam-auth-update.in`: the program. `make` fills in `@DATADIR@` and
  `@VERSION@` and writes `pam-auth-update`, which is not checked in. The
  awk part is a here-document in the script (`AWK_PROGRAM`), so that one
  file is installed.
* `pam-securetty`: installed as it is.
* `templates/common-*`: what a new file is made from.
* `profiles/unix`: the profile for pam_unix. It is Debian's, with sha512
  for new password hashes in place of yescrypt: musl cannot do yescrypt,
  and the hashes have to work on musl and on glibc systems alike.
* `man/pam-auth-update.8`: the manual page, written in roff by hand.
* `tests/run-tests`: the tests, with their profiles in `tests/profiles/`.
* `tests/compare-with-debian`: compares the output with that of Debian's
  program, on a Debian host.
* `Makefile`: `make`, `make check`, `make install`, `make dist`. The
  version is set there.

## Commands

    make
    make check
    AWK="busybox awk" TEST_SHELL="busybox sh" sh tests/run-tests
    sh tests/compare-with-debian
    checkbashisms pam-auth-update pam-securetty tests/run-tests

Run `make` before the tests, they call the generated `pam-auth-update`.
Run the tests with dash and with the shell of busybox, and with gawk,
mawk and the awk of busybox: a minimal system has only busybox.

## Conventions

* POSIX shell (`#!/bin/sh`) and POSIX awk only. No bashisms, and nothing
  that only gawk has (`asort`, `gensub`, `length` of an array, the third
  argument of `match`). No dependency on Perl, Python or anything else
  that is not on a minimal system.
* In the shell part variables of the script are in capitals, the ones of
  a function start with an underscore. In the awk part globals are in
  capitals, locals are extra parameters after four blanks.
* Input reaches awk through the environment (`PAU_*`), not through `-v`
  or the command line.
* Errors go to stderr as `pam-auth-update: error: ...` and end the
  program with status 1, before anything was written.
* The five files are written next to the ones they replace
  (`.pam-new`) and renamed only when all of them are there and have their
  markers. Keep it that way: no file is edited in place.

## Compatibility with Debian

* The format of the profiles, the four marker lines of the templates and
  what is written between them stay as Debian has them, so that a profile
  of a Debian package can be used unchanged.
  `tests/compare-with-debian` has to keep saying that all files are the
  same.
* Where the program does something else than Debian's on purpose, the
  manual page says so under DIFFERENCES and the comment at the top of
  `pam-auth-update.in` does too. Add to both when another difference is
  introduced.
* The files in `/var/lib/pam` are not Debian's.

## Licenses

* `pam-auth-update` is under version 3 of the GNU General Public License,
  like the program it is based on. The header keeps the copyright line of
  Canonical and the note about where it comes from.
* `pam-securetty` is in the public domain.
* The templates and the profile come from Debian's packaging of PAM.
  Don't copy from other sources without noting where it came from and
  under which license.

## Related repositories (next to this one)

* `../aeltra-ports`: package recipes. PAM itself is `core/p/pam`, with
  Debian's patches.
* `../aeltra-bootstrap`: `BOOTSTRAP-NOTES.md` and `TODO.md` have the
  notes on PAM and on how this package is to be used.
