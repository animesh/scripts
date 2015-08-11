#!/usr/bin/env perl

# A test for darcs resolve detecting a conflict, inspired by bug #152 in RT

use lib 'lib/perl';
use Test::Darcs;
use Test::More tests => 6;
use strict;
use vars qw/$DARCS/;

die 'darcs not found' unless $ENV{DARCS} || (-x "$ENV{PWD}/../darcs");
$DARCS = $ENV{DARCS} || "$ENV{PWD}/../darcs";

use ExtUtils::Command;

cleanup 'tmp1';
`mkdir tmp1`;
chdir 'tmp1' || die;
`$DARCS init`;

open(T1,">one.txt");
print T1 "from tmp1";
close(T1);

`$DARCS add one.txt`;
`$DARCS rec -A bar -am "add one.txt"`;

open(T1,">>one.txt");
print T1 "\n";
close(T1);

open(PREF,">_darcs/prefs/defaults");
print PREF "apply allow-conflicts\n";
close(PREF);

chdir "../";
`rm -rf tmp2`;
`darcs get tmp1 tmp2`;
chdir "tmp2/";

open(T2,">>one.txt");
print T2 "in tmp2\n";
close(T2);

`darcs rec -A bar -am "add extra line"`;

like(`darcs push -a`,qr/conflicts/i,'expect conflicts when pushing');  
chdir '../tmp1';

TODO: {
    local $TODO = 'waiting on code to fix this';
    unlike(`darcs resolve`,qr/no conflicts/i, "after a conflict, darcs resolve should report a conflict");
}

chdir '../';
for my $dir (qw/tmp1 tmp2/) {
    ok(-d $dir, "$dir exists here");
    #rm_rf($dir);
    `rm -rf $dir`;
    ok((!-d $dir), "$dir directory was deleted");
}





