#!/usr/bin/env perl

# Some tests for 'darcs annotate'

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

###

my $test_name = 'record something';

`date >> date.t`;
`$DARCS add date.t`;

like(`$DARCS record -A 'Mark Stosberg <a\@b.com>' -a -m foo date.t 2>&1`, qr/finished recording/i, $test_name);

####

like(`$DARCS annotate --xml date.t `,qr/&lt;a\@b.com&gt;/,'annotate --xml encodes < and >');

chdir '../';
`rm -rf temp1`;
ok((!-d 'temp1'), 'temp1 directory was deleted');




