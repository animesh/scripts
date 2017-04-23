#!/usr/bin/env perl

# Some tests for 'darcs whatsnew '

use lib 'lib/perl';
use Test::More qw/no_plan/;
use Shell::Command;
use Test::Darcs;
use strict;

cleanup 'temp1';
mkpath 'temp1';
chdir 'temp1';
darcs 'init';
touch('look_summary.txt');

{
    my $test_name = '--disable works on command line';
    like( darcs('whatsnew -sl --disable'), qr!disable!i, $test_name);
}

{
    my $test_name = '--disable works from defaults';
    open(FOO,'>_darcs/prefs/defaults');
    print FOO "whatsnew --disable\n";
    close(FOO);
    like( darcs('whatsnew -sl'), qr!disable!i, $test_name);
}

chdir '../';
cleanup('temp1');
ok((!-d 'temp1'), 'temp1 directory was deleted');




