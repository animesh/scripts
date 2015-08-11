#!/usr/bin/env perl

# Some tests for the output of changes when combined with move.

use lib 'lib/perl';
use Test::Darcs;
use Test::More qw/no_plan/;
use strict;
use vars qw/$DARCS/;

die 'darcs not found' unless $ENV{DARCS} || (-x "$ENV{PWD}/../darcs");
$DARCS = $ENV{DARCS} || "$ENV{PWD}/../darcs";



cleanup 'temp1';
`mkdir temp1`;
chdir 'temp1';
`$DARCS init`;
open (DEF, ">_darcs/prefs/defaults") || die "Couldn't write to defaults.";
print DEF "ALL --author tester";
print DEF "ALL --ignore-times";
close(DEF);

`date > foo`; # create foo!

like(`$DARCS add foo`, qr/^$/,
     "darcs add reports nothing");

like(`$DARCS record -m 'add foo' -a`, qr/Finished recording patch 'add foo'/,
     "darcs record reports 'Finished recording patch 'add foo''");

`mkdir d`;

like(`$DARCS add d`, qr/^$/,
     "darcs add reports nothing");

like(`$DARCS record -m 'add d' -a`, qr/Finished recording patch 'add d'/,
     "darcs record reports 'Finished recording patch 'add d''");

like(`$DARCS mv foo d`, qr/^$/,
     "darcs mv reports nothing");

like(`$DARCS record -m 'mv foo to d' -a`,
     qr/Finished recording patch 'mv foo to d'/,
     "darcs record reports 'Finished recording patch 'mv foo to d''");

like(`$DARCS mv d directory`, qr/^$/,
     "darcs mv reports nothing");

like(`$DARCS record -m 'mv d to directory' -a`,
     qr/Finished recording patch 'mv d to directory'/,
     "darcs record reports 'Finished recording patch 'mv d to directory''");

`echo How beauteous mankind is > directory/foo`;

like(`$DARCS record -m 'modify directory/foo' -a`,
     qr/Finished recording patch 'modify directory\/foo'/,
     "darcs record reports 'Finished recording patch 'modify directory/foo''");

my $changes_output = `$DARCS changes directory/foo`;
like($changes_output, qr/add foo/,
     "darcs changes reports 'add foo'");
like($changes_output, qr/mv foo to d/,
     "darcs changes reports 'mv foo to d'");

`echo O brave new world > directory/foo`;
like(`$DARCS mv directory/foo directory/bar`, qr/^$/,
     "darcs mv reports nothing");

`echo That has such people in it > directory/foo`;
like(`$DARCS add directory/foo`, qr/^$/,
     "darcs add reports nothing");

like(`$DARCS record -m 'mv foo then add new foo' -a`,
     qr/Finished recording patch 'mv foo then add new foo'/,
     "darcs record reports 'Finished recording patch 'mv foo then add new foo''");

my $annotate_output = `$DARCS annotate directory/bar`;
like($annotate_output, qr/How beauteous mankind is/,
     "darcs annotate reports 'How beauteous mankind is'");
like($annotate_output, qr/O brave new world/,
     "darcs annotate reports 'O brave new world'");

#my $annotate_output = `$DARCS annotate directory/foo`;
#like($annotate_output, qr/That has such people in it/,
#     "darcs annotate reports 'That has such people in it'");


chdir '../';
`rm -rf temp1`;
ok((!-d 'temp1'), 'temp1 directory was deleted');




