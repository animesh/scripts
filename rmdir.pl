#!/usr/bin/env perl

use lib qw(lib/perl);

use Test::More qw/no_plan/;

use Test::Darcs;
use Shell::Command;

use strict;

# vanilla rmdir
cleanup 'temp1';
mkpath 'temp1';
chdir 'temp1';
darcs 'init';
mkpath 'foo';
`echo hello world > foo/bar`;
`echo hello world > foo/baz`;
mkpath 'foo/dir';
darcs 'add foo foo/bar foo/dir foo/baz';
darcs 'record -a -m add -A x';
cleanup 'foo';
ok(-e '_darcs/pristine/foo/baz');
ok(-d '_darcs/pristine/foo/dir');
ok(-e '_darcs/pristine/foo/bar');
ok(-d '_darcs/pristine/foo');
darcs 'record -a -m del -A x';
ok(! -e '_darcs/pristine/foo/baz');
ok(! -d '_darcs/pristine/foo/dir');
ok(! -e '_darcs/pristine/foo/bar');
ok(! -d '_darcs/pristine/foo');
chdir '..';
cleanup 'temp1';

sub setupTemp1Temp2() {
  cleanup 'temp1';
  cleanup 'temp2';

  # initialise temp1
  mkpath 'temp1';
  chdir 'temp1';
  darcs 'init';
  mkpath 'foo';
  `echo hello world > foo/bar`;
  darcs 'add foo foo/bar';
  darcs 'record -a -m add -A x';
  chdir '..';

  # get temp1 into temp2
  darcs 'get temp1 temp2';
  chdir 'temp2';
  `echo hello world > foo/baz`;
  chdir '..';

  # remove a directory from temp1 and record
  chdir 'temp1';
  cleanup 'foo';
  darcs 'record -a -m del -A x';
  chdir '..';
}

sub checkTemp2Prepull() {
  chdir 'temp2';
  ok(-e 'foo/baz');
  ok(-e 'foo/bar');
  ok(-d 'foo');
  ok(-e '_darcs/pristine/foo/bar');
  ok(-d '_darcs/pristine/foo');
  chdir '..';
}

sub checkTemp2Postpull() {
  chdir 'temp2';
  # the directory and temp2-specific file should still be there
  ok(-e 'foo');
  ok(-e 'foo/baz');
  # but the pristine stuff should be gone
  ok(! -e '_darcs/pristine/foo/bar');
  ok(! -d '_darcs/pristine/foo');
  chdir '..';
}

# it should be ok to apply a rmdir patch on a non-empty directory in working
# get temp2 and add some extra stuff to the directory
setupTemp1Temp2;
checkTemp2Prepull;
like(darcs(qw(pull -a --repodir=temp2)), qr(not empty));
checkTemp2Postpull;
# same test as above, but be vewy vewy quiet
setupTemp1Temp2;
checkTemp2Prepull;
unlike(darcs(qw(pull -a --repodir=temp2 --quiet)), qr(.+));
checkTemp2Postpull;
# make sure that a messed up pristine still creates an error
setupTemp1Temp2;
`echo hello world > temp2/_darcs/pristine/foo/blop`;
checkTemp2Prepull;
like(darcs(qw(pull -a --repodir=temp2)), qr(inconsistent state));

cleanup 'temp1';
cleanup 'temp2';
