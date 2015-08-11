#!/usr/bin/env perl

# A start on testing amend-record. Please add more tests for amend here!

use lib 'lib/perl';
use Test::More qw/no_plan/;
use strict;
use Test::Darcs;
use Shell::Command;


cleanup 'temp1';
mkpath 'temp1';
chdir 'temp1';

like( darcs('init'), qr/^$/i, 'initialized repo');
`echo "Tester" > _darcs/prefs/author`;
`echo ALL ignore-times >> _darcs/prefs/defaults`;

# Plain amend-record
touch('foo');
darcs("add foo");
like( darcs("record -a -m add_foo"), qr/finished recording/i, 'added patch');
open(F, ">>foo") || die;
print F "another line";
close(F);

like( echo_to_darcs("y","amend-record -a foo"), qr/amending changes/i, 'amend-record -a');
is($?,0, " return code == 0");

{
  my $changes = darcs("changes -v");
  like( $changes, qr/another line/, 'change amended properly');
}

# Special case: patch is empty after amend
cp "foo","foo.old";

open(F, ">>foo") || die;
print F "another line";
close(F);

like( darcs("record -a -m add_line foo"), qr/finished recording/i, 'record');
mv "foo.old","foo";
like( echo_to_darcs("y","amend -a foo"), qr/amending changes/i, 'amend makes empty patch');
is($?,0, "  return code == 0");
chdir '../';
rm_rf 'temp1';




