#!/usr/bin/env perl

# Some tests for the repodir flag

use lib qw(lib/perl);

use Test::More qw/no_plan/;

use Test::Darcs;
use Shell::Command;

use strict;

my $test_name = 'Make sure that a simple init works.';
cleanup  'temp1';
mkpath 'temp1';
chdir  'temp1';
darcs 'init';
ok((-d '_darcs'), '_darcs directory was created');

$test_name = 'Make sure that init in a pre-existing darcs directory fails.';
like(darcs('init'), qr/not run this command in a repository/, $test_name);

$test_name = 'Make sure that init --repodir creates the directory if it does not exist';
chdir '../';
cleanup 'temp1';
darcs 'init --repodir=temp1';
ok((-d 'temp1/_darcs'), '_darcs directory was created');

# cleanup
chdir '../';
cleanup 'temp1';
ok((!-d 'temp1'), 'temp1 directory was deleted');
