#!/usr/bin/env perl

# Some tests for the repodir flag

use lib qw(lib/perl);

use Test::More qw/no_plan/;

use Test::Darcs;
use Shell::Command;

use strict;

cleanup 'temp1';
cleanup 'temp2';
mkpath 'temp1';

my $repo_flag = '--repodir=temp1';
my $test_name = 'Make sure that init works with --repodir';
darcs "init $repo_flag";
ok((-d 'temp1/_darcs'), '_darcs directory was created');

# add some meat to that repository 
chdir 'temp1';
touch 'baz';
darcs qw( add baz ) ;
darcs qw( record -A me -m moo -a ) ;
chdir '../';

$test_name = 'get accepts --repodir.';
like( darcs("get --repodir=temp2 temp1"), qr/Finished getting/i, $test_name );
ok((-d 'temp2/_darcs'), '_darcs directory was created');
cleanup 'temp2';
$test_name = 'get accepts absolute --repodir.';
like( darcs("get --repodir=`pwd`/temp2 temp1"), qr/Finished getting/i, $test_name );
ok((-d 'temp2/_darcs'), '_darcs directory was created');

$test_name = 'changes accepts --repodir.';
like( darcs("changes $repo_flag"), qr/moo/i, $test_name );
$test_name = 'changes accepts absolute --repo.';
like( darcs("changes --repo=`pwd`/temp1"), qr/moo/i, $test_name );
TODO: {
  local $TODO = 'waiting on coding';
  $test_name = 'changes accepts relative --repo.';
  like( darcs("changes --repo=temp1"), qr/moo/i, $test_name );
}

$test_name = 'dist accepts --repodir.';
like( darcs("dist $repo_flag"), qr/Created dist/i, $test_name );

$test_name = 'optimize accepts --repodir.';
like( darcs("optimize --reorder-patches $repo_flag"), qr/done optimizing/i, $test_name );

$test_name = 'repair accepts --repodir.';
like( darcs("repair $repo_flag"), qr/already consistent/i, $test_name );

$test_name = 'replace accepts --repodir.';
like( darcs("replace $repo_flag foo bar"), qr//i, $test_name );

$test_name = 'setpref accepts --repodir.';
like( darcs("setpref $repo_flag test echo"), qr/Changing value of test/i, $test_name );

$test_name = 'trackdown accepts --repodir.';
like( darcs("trackdown $repo_flag"), qr/Success!/i, $test_name );

# cleanup
chdir '../';
cleanup 'temp1';
ok((!-d 'temp1'), 'temp1 directory was deleted');
cleanup 'temp2';
ok((!-d 'temp2'), 'temp1 directory was deleted');
