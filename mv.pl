#!/usr/bin/env perl

# Some tests for 'darcs mv'

use lib ('lib/perl');
use Test::More tests => 13;
use Test::Darcs;
use Cwd;
use Shell::Command;
use strict;
use Carp;

cleanup 'temp1';
mkdir 'temp1';
chdir 'temp1';
darcs 'init';

###

my $test_name = 'adding a directory with more than one ../ in it should work.';
mkpath('foo.d/second/third','foo.d/other') || die "mkpath failed: $!";

my $out = `ls ./foo.d/other`;
print $out;

touch './foo.d/other/date.t';
darcs qw/add -r foo.d/;

chdir 'foo.d/second/third';

my $mv_out = darcs qw!mv ../../other/date.t ../../other/date_moved.t!;
unlike($mv_out, qr/darcs failed/, $test_name);

chdir '../../../';
$test_name = 'refuses to move to an existing file';
touch 'ping';
touch 'pong';
darcs qw/add ping pong/;
like(darcs(qw( mv ping pong )), qr/already exists/,$test_name);

# case sensitivity series
# -----------------------
# these are tests designed to check out darcs behave wrt to renames 
# where the case of the file becomes important

# are we on a case sensitive file system?
my $is_case_sensitive = 1;
touch 'is_it_cs';
touch 'IS_IT_CS';
my @csStat1=stat 'is_it_cs';
my @csStat2=stat 'IS_IT_CS';
if ($csStat1[1] eq $csStat2[1]) {
  $is_case_sensitive = 0;
} 
my $already_exists = qr/already exists/;
my $no_test_cuz_insensitive = "This test can't be run becase the file system is case insensitive";

# if the new file already exists - we don't allow it
# basically the same test as mv ping pong, except we do mv ping PING
# and both ping and PING exist on the filesystem
$test_name = "case sensitivity - simply don't allow mv if new file exists";
touch 'cs-n-1'; touch 'CS-N-1';
touch 'cs-y-1'; touch 'CS-Y-1';
darcs qw/add cs-n-1 cs-y-1/;
if ($is_case_sensitive) {
  # regardless of case-ok, we do NOT want this mv at all
  like(darcs(qw( mv           cs-n-1 CS-N-1)), $already_exists, $test_name);
  like(darcs(qw( mv --case-ok cs-y-1 CS-Y-1)), $already_exists, $test_name);
} else {
  pass ( $no_test_cuz_insensitive );
  pass ( $no_test_cuz_insensitive );
}

# if the new file does not already exist - we allow it
$test_name = "case sensitivity - the new file does *not* exist";
touch 'cs-n-2'; 
touch 'cs-y-2'; 
darcs qw/add cs-n-2/;
# these mv's should be allowed regardless of flag or filesystem
unlike(darcs(qw( mv           cs-n-2 CS-N-2)), $already_exists, $test_name);
unlike(darcs(qw( mv --case-ok cs-y-2 CS-Y-2)), $already_exists, $test_name);

# parasites - do not accidentally overwrite a file just because it has a
# similar name and points to the same inode.  We want to check if a file if the
# same NAME already exists - we shouldn't care about what the actual file is!
$test_name = "case sensitivity - inode check"; 
touch 'cs-n-3'; 
touch 'cs-y-3'; 
darcs qw/add cs-n-3 cs-y-3/;
if ($^O =~ /msys/i) {
  # afaik, windows does not support hard links
  pass ('cannot run this test -- windows does not have hard links');
} elsif ($is_case_sensitive) {
  `ln cs-n-3 CS-N-3`;
  `ln cs-y-3 CS-Y-3`;
  # regardless of case-ok, we do NOT want this mv at all
  like(darcs(qw( mv           cs-n-3 CS-N-3)), $already_exists, $test_name);
  like(darcs(qw( mv --case-ok cs-y-3 CS-Y-3)), $already_exists, $test_name);
} else {
  pass ( $no_test_cuz_insensitive );
  pass ( $no_test_cuz_insensitive );
}

# parasites - we don't allow weird stuff like mv foo bar/foo just because
# we opened up some crazy exception based on foo's name
$test_name = 'refuses to move to an existing file with same name, different path';
touch 'cs-n-4'; touch 'foo.d/cs-n-4';
touch 'cs-y-4'; touch 'foo.d/cs-y-4';
darcs qw/add cs-n-4/;
# regardless of case-ok, we do NOT want this mv at all 
like(darcs(qw( mv           cs-n-4 foo.d/cs-n-4)), $already_exists, $test_name);
like(darcs(qw( mv --case-ok cs-y-4 foo.d/cs-y-4)), $already_exists, $test_name);

# ---------------------------
# end case sensitivity series

touch 'abs_path.t';
darcs qw/add abs_path.t/;

{
  my $repo_abs = `pwd`;
  my $mv_out =  darcs(qw( mv $repo_abs/abs_path.t abs_path_new.t ));
  unlike($mv_out, qr/darcs failed/, 'mv should work with absolute path as a src argument.');
}

{
  my $repo_abs = `pwd`;
  my $mv_out = darcs(qw( mv abs_path.t $repo_abs/abs_path_new.t));
  unlike($mv_out, qr/darcs failed/, 'mv should work with absolute path as a target argument.');
}

chdir '..';
cleanup 'temp1';
ok((!-d 'temp1'), 'temp1 directory was deleted');
