#!/usr/bin/env perl

# Some tests for the behavior when there is a conflict in _darcs/patches/pending

use Test::More qw/no_plan/;
use lib ('lib/perl');
use Test::Darcs;
use Shell::Command;
use strict;
use vars qw/$DARCS/;

die 'darcs not found' unless $ENV{DARCS} || (-x "$ENV{PWD}/../darcs");
$DARCS = $ENV{DARCS} || "$ENV{PWD}/../darcs";

cleanup  'temp1';
mkpath 'temp1';
chdir 'temp1';
darcs 'init';
open(PENDING,'>_darcs/patches/pending') || die "couldn't open pending: $!";
print PENDING '{
    addfile ./date.t
    addfile ./date_moved.t
    move ./date.t ./date_moved.t
}';
close(PENDING); 

# now watch the fireworks as all sorts of things fail
like( darcs ('whatsnew'), qr/pending has conflicts/, "darcs whatsnew reports 'pending has conflicts'");

####

my $revert_output = `echo y | $DARCS revert -a 2>&1`;
like($revert_output, qr/pending has conflicts/, 'darcs revert reports "pending has conflicts"');

###

my $record_output =  darcs(qw/record -A x -a -m foo/);
like($record_output, qr/pending has conflicts/, 'darcs record reports "pending has conflicts"');

like( darcs('repair'), qr/The repository is already consistent, no changes made/i, 'darcs repair finds no problem');

chdir '../';
cleanup 'temp1';
ok((!-d 'temp1'), 'temp1 directory was deleted');




