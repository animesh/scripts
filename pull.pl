#!/usr/bin/env perl

# Some tests for 'darcs pull' 

use Test::More qw/no_plan/;
use lib ('lib/perl');
use Test::Darcs;
use strict;
use Cwd;
use vars qw/$DARCS/;
use POSIX qw/getuid/;

die 'darcs not found' unless $ENV{DARCS} || (-x "$ENV{PWD}/../darcs");
$DARCS = $ENV{DARCS} || "$ENV{PWD}/../darcs";

cleanup 'temp1';
cleanup 'temp2';
`mkdir -p temp1 temp2/one/two`;
chdir 'temp1';
`$DARCS init`;
chdir '../temp2';
`$DARCS init`;
chdir 'one/two';

{
    my $test_name = 'darcs pull should work relative to the current directory';
    my $pull_out = `$DARCS pull -a ../../../temp1 2>&1`;
    like($pull_out, qr/No remote changes to pull in/i, $test_name);
}

my $test_name = 'darcs pull should pull into repo specified with --repo';
chdir '../../';  # now in temp2
`$DARCS add one`;
`$DARCS record --patch-name 'uno' --all --author foo\@bar`;
chdir '../';     # now outside of any repo
like(`$DARCS pull --repodir temp1 --all ../temp2`, # temp2 is relative to temp1
	qr/Finished pulling./i, $test_name);

TAKE_LOCK: {
    # set up server repo
    `date >>temp2/one/date.t`;
    `$DARCS add --repodir ./temp2 one/date.t`;
    `$DARCS record --repodir ./temp2 --author foo\@far.com -a -m 'foo'`;

    # set up client repo for failure
    `chmod -w ./temp1/one/`;
    my $out = `$DARCS pull --repodir ./temp1 -a 2>&1`;
    if ($^O =~ /msys/i) {
        pass('this test fails on windows, so ignore it');
    } else {
      if(getuid() == 0) {
        pass("root never gets permission denied");
      } else {
        like($out, qr#one/date\.t.+: permission denied#i,
             'expect permission denied error');
      }
    }
};


SELF_PULL: {
    chdir './temp1'; 

    my $default_repo_pre_test = 'Before trying to pull from self, defaultrepo is something else';
    open(DEFAULT_REPO,'<./_darcs/prefs/defaultrepo') || die "Couldn't open defaultrepo";
    my $default_repo = (<DEFAULT_REPO>);
    close(DEFAULT_REPO);

    unlike($default_repo,qr/temp1/,$default_repo_pre_test);

    my $test_name = 'return special message when you try to pull from yourself';
    my $abs_path = cwd();
    like(`$DARCS pull -a $abs_path 2>&1`, qr/Can.t pull from current repository!/i, $test_name);

    my $set_default_repo_test = "and do not update the default repo to be the current dir";
    open(DEFAULT_REPO,'<./_darcs/prefs/defaultrepo') || die "Could not open defaultrepo";
    my $new_default_repo = (<DEFAULT_REPO>);
    close(DEFAULT_REPO);

    unlike($new_default_repo,qr/temp1/,$set_default_repo_test);

    chdir '../';     # now outside of any repo
}

ROLLBACK_PULL: {
    use File::Path;
    chdir 'temp1';
    `echo a > foo`;
    darcs 'record -lam A --author foo@bar';
    `echo b > foo`;
    darcs 'record --ignore-times -lam B --author foo@bar';
    `echo c > foo`;
    darcs 'record --ignore-times -lam C --author foo@bar';
    `echo -n y | $DARCS rollback -p C`;
    chdir '../';
    rmtree('temp2/');
    darcs 'get --to-patch B temp1 temp2';
    chdir('temp2');
    system "sleep 1"; # So that rollback won't have same timestamp as get.
    `echo -n y | $DARCS rollback -p B`;
    `$DARCS revert -a`;
    my $pull_out = `$DARCS pull -a ../temp1 2>&1`;
    unlike($pull_out,qr/Error applying patch/i,
           'pull after rollback avoids failure');
    chdir '../';
};

NONEWLINES_PULL: {
  chdir 'temp1';
  `echo -n foo > baz`;
  darcs 'add baz';
  darcs 'record --ignore-times -am newbaz --author me';
  chdir '../temp2';
  like(darcs('pull -a'), qr/Finished pulling/, 'pull of newlineless patch');
  `echo -n bar > baz`;
  darcs 'record --ignore-times -am bazbar --author me';
  chdir '../temp1';
  like(darcs('pull ../temp2 -a'), qr/Finished pulling/,
       'pull of newlineless patch');
  `echo -n bar > correct_baz`;
  ok(!(system "diff baz correct_baz"), 'pull was right');
  chdir '..';
}

CREATE_DIR_ERROR: {
   my $test_name = "when a patch creating a directory is attempted to be applied
       when an existing directory, exists, a warning is raised, but the pull
       succeeds.";
   mkdir 'temp1/newdir';
   chdir 'templ/';
   ok((chdir 'temp1/'), "chdir succeeds");;
   darcs 'add newdir';
   darcs 'record --ignore-times -am newdir --author me';
   ok((chdir '../temp2'), "chdir succeeds");;
   mkdir 'newdir';
   my $out = darcs('pull -a ../temp1');
   like($out, qr/Warning: /i, $test_name);
   like($out, qr/Finished pulling/i, $test_name);
   {
      local $TODO = 'awaiting attention from a Haskell coder.';
      like($out, qr/newdir/i, "...and report the name if the directory involved");
   }
   ok((chdir '../'), "chdir succeeds");;
}

ok(-d 'temp1', "temp1 exists here") || `ls -l`;
rmtree('temp1');
ok((!-d 'temp1'), 'temp1 directory was deleted');

ok(-d 'temp2', "temp2 exists here");
rmtree('temp2');
ok((!-d 'temp2'), 'temp2 directory was deleted');




