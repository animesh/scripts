#!/usr/bin/env perl

# Some tests for launching external commands

use lib qw(lib/perl);

use Test::More qw/no_plan/;

use Test::Darcs;
use Shell::Command;

use strict;

cleanup  'temp1';
mkpath 'temp1';
chdir  'temp1';
darcs 'init';

my $touch_fakessh='touch-fakessh';
$touch_fakessh.='.bat' if ($^O =~ /msys/i);

cleanup  'fakessh';
cleanup  'touch-fakessh';
###

# make our ssh command one word only
`echo 'echo hello > fakessh' > $touch_fakessh`;
`chmod u+x $touch_fakessh`;
# add our fake ssh command to the environment
$ENV{DARCS_SSH}="./$touch_fakessh";
$ENV{DARCS_SCP}="./$touch_fakessh";
$ENV{DARCS_SFTP}="./$touch_fakessh";
# first test the DARCS_SSH environment variable
darcs(qw(get foo.bar:baz));
ok(-e 'fakessh');
cleanup 'fakessh';
# now make sure that we don't launch ssh for nothing
cleanup  'temp2';
darcs(qw(get temp2));
ok(! -e 'fakessh');
darcs(qw(get http://foo.bar:baz));
ok(! -e 'fakessh');

chdir '..';
cleanup 'temp1';
