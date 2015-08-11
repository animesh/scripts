#!/usr/bin/env perl

# Some tests for 'darcs put' 

use lib ('lib/perl');
use Test::More qw/no_plan/;
use Test::Darcs;
use Shell::Command;
use Cwd;
use strict;

cleanup  qw/temp1 temp2/;
mkpath 'temp1';
chdir 'temp1';
darcs 'init';
chdir '../';

{
  my $test_name = 'put should set default repo';
  chdir './temp1';
  touch '1.txt';
  darcs qw/add 1.txt/;
  darcs (qw/record -A x -a -m foo 1.txt/);
  darcs (qw% put ../temp2 %);
  
  my $default_repo;
  if (ok(open(DEFAULT_REPO,'<_darcs/prefs/defaultrepo'),"put populates defaultrepo")) {
    $default_repo = (<DEFAULT_REPO>);
    close(DEFAULT_REPO);
  }
  
  like($default_repo,qr/temp2/,$test_name);
  chdir '../';
}


SELF_PUT: {
    chdir './temp1'; 

    my $default_repo_pre_test = 'Before trying to put from self, defaultrepo is something else';
    my $default_repo;
    if (open(DEFAULT_REPO,'<./_darcs/prefs/defaultrepo')) {
      $default_repo = (<DEFAULT_REPO>);
      close(DEFAULT_REPO);
    }

    unlike($default_repo,qr/temp1/,$default_repo_pre_test);

    my $test_name = 'return special message when you try to put put yourself';
    my $abs_path = cwd();
    my $out = darcs "put $abs_path";
    like($out , qr/Can't put.*current repository!/i, $test_name);

    my $set_default_repo_test = "and don't update the default repo to be the current dir";
    my $new_default_repo;
    if (open(DEFAULT_REPO,'<./_darcs/prefs/defaultrepo')) {
        $new_default_repo = (<DEFAULT_REPO>);
        close(DEFAULT_REPO);
    }

    unlike($new_default_repo,qr/temp1/,$set_default_repo_test);

    chdir '../';     # now outside of any repo
}


ok(-d 'temp1', "temp1 exists here");
cleanup 'temp1';
ok((!-d 'temp1'), 'temp1 directory was deleted');

ok(-d 'temp2', "temp2 exists here");
cleanup 'temp2';
ok((!-d 'temp2'), 'temp2 directory was deleted');




