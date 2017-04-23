#!/usr/bin/env perl

use lib 'lib/perl';
use Test::More qw/no_plan/;
use Shell::Command;
use Test::Darcs;
use Shell::Command;
use strict;

cleanup 'temp1';
mkpath 'temp1';
chdir 'temp1';
darcs 'init';
open (DEF, ">_darcs/prefs/defaults") || die "Couldn't write to defaults.";
print DEF "ALL --author tester";
print DEF "ALL --ignore-times";
close(DEF);

{
  my $testname = "RT#544 using context created with 8-bit chars";
  touch 'foo';
  like ( darcs("record -la -m 'add\212 foo'"), qr/Finished record/,
         'recorded patch adding foo');
  my $context = darcs('changes --context');
  open(CON, ">context");
  print CON $context;
  close(CON);
  system 'date > foo';
  like ( darcs("record -a -m 'date foo'"), qr/Finished record/,
         'recorded patch modifying foo');
  like ( darcs('send -a -o patch --context context .'), qr/^$/, $testname );
}

chdir '../';
cleanup('temp1');
ok((!-d 'temp1'), 'temp1 directory was deleted');




