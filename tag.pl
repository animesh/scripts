#!/usr/bin/env perl

# Some tests for 'darcs tag' 

use lib 'lib/perl';
use Test::Darcs;
use Test::More qw/no_plan/;
use strict;
use vars qw/$DARCS/;

die 'darcs not found' unless $ENV{DARCS} || (-x "$ENV{PWD}/../darcs");
$DARCS = $ENV{DARCS} || "$ENV{PWD}/../darcs";

cleanup 'temp1';
`mkdir -p temp1`; 
chdir 'temp1';
`$DARCS init`;
`touch one`;
`$DARCS add one`;
`$DARCS record --patch-name 'uno' --all --author foo\@bar`;
my $tag_out = `$DARCS tag -A me soup 2>&1`;
unlike($tag_out, qr/failed/i, 'tagging with tag name on the command line avoids failure');
like($tag_out, qr/TAG/,      'tagging reports success with TAG');

my $changes_out = `$DARCS changes --last 1 2>&1`;

like($changes_out,qr/tagged/, 'tagging includes "tagged" in tag name.');

chdir '../';
ok(-d 'temp1', "temp1 exists here");
`rm -rf temp1`;
ok((!-d 'temp1'), 'temp1 directory was deleted');





