#!/usr/bin/env perl

# Some tests for 'darcs push' 

use lib qw(lib/perl);
use Test::More tests => 10;
use Test::Darcs;
use Shell::Command;
use strict;

cleanup  'temp1';
cleanup  'temp2';
mkpath 'temp1';
mkpath 'temp2/one/two';
chdir 'temp1';
darcs 'init';
chdir '../temp2';
darcs 'init';
chdir '../';

{
    my $test_name = 'push without a repo gives an error';
    chdir './temp1';
    my $out = darcs qw/push -p 123/;
    like($out,qr/missing argument/i,$test_name);
    chdir '../';
}

{
    chdir './temp2/one/two';
    my $test_name = 'darcs push should work relative to the current directory';
    my $push_out = darcs qw!push -a ../../../temp1!;
    like($push_out, qr/No recorded local changes to push/i, $test_name);
    chdir '../../../'; # above temp repos
}

{
    my $test_name = 'darcs push should push into repo specified with --repo';
    chdir './temp2';  
    darcs  qw/add one/;
    darcs qw!record --patch-name 'uno' --all --author foo\@bar!;
    chdir '../';     # now outside of any repo

    like(darcs(qw!push --repodir temp2 --all ../temp1!), # temp2 is relative to temp1
            qr/Finished apply./i, $test_name);
}



SELF_PUSH: {
    chdir './temp1'; 

    my $default_repo_pre_test = 'Before trying to pull from self, defaultrepo does not exist';
    ok( (! -r './_darcs/prefs/defaultrepo'),$default_repo_pre_test);

    my $test_name = 'return special message when you try to push to yourself';
    use Cwd;
    like( darcs(qw/push -a/,getcwd()), qr/Can't push to current repository!/i, $test_name);

    my $set_default_repo_test = "and don't update the default repo to be the current dir";
    ok( (! -r './_darcs/prefs/defaultrepo'),$set_default_repo_test);

    chdir '../';     # now outside of any repo
}

ok(-d 'temp1', "temp1 exists here");
cleanup 'temp1';
ok((!-d 'temp1'), 'temp1 directory was deleted');

ok(-d 'temp2', "temp2 exists here");
cleanup 'temp2';
ok((!-d 'temp2'), 'temp2 directory was deleted');




