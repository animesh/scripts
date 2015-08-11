#!/usr/bin/env perl

# Some tests for 'darcs whatsnew '

use lib 'lib/perl';
use Test::More qw/no_plan/;
use Shell::Command;
use Test::Darcs;
use Shell::Command;
use strict;

cleanup 'temp1';
mkpath 'temp1';
chdir 'temp1';
darcs 'init';
open (DEF, ">_darcs/prefs/defaults") || die "Couldn't write to defaults.";
print DEF "ALL --author tester";
print DEF "ALL --ignore-times";
close(DEF);

{
  my $testname = "RT#505 whatsnew -s after removal of file without a newline";
  open(FOO,'>foo');
  print FOO "foobar";
  close(FOO);
  like ( darcs('record -la -m "add foo"'), qr/Finished record/,
         'recorded patch adding foo');
  rm_rf 'foo';
  like ( darcs('whatsnew -s'), qr/R/, $testname );
  darcs 'record -a -m "remove foo"';
}

{
    my $test_name = 'RT#245 --look-for-adds implies --summary';
    touch('look_summary.txt');
    like( darcs('whatsnew -l'), qr!a ./look_summary.txt!i, $test_name);
}


my $test_name = 'whatsnew works with uncommon file names';

if ($^O =~ /msys/i) {
    pass 'test does not work on windows';
} else {
    touch(qw/\\/);

    my $before  = darcs(qw/add \\\\/);
    my $what = darcs('whatsnew');
    unlike($what, qr/no changes/i, $test_name);
}

{
    my $test_name = 'whatsnew works with absolute paths';
    my $abs_repo_path = `pwd`;
    open(FOO,'>date.t');
    print FOO "date.t";
    close(FOO);
    touch('date.t');
    darcs(qw/add date.t/);
    like( darcs('whatsnew', $abs_repo_path."/date.t"), qr/hunk/i, $test_name);
}

chdir '../';
cleanup('temp1');
ok((!-d 'temp1'), 'temp1 directory was deleted');




