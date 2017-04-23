#!/usr/bin/env perl

# Some tests for 'darcs add'

use lib qw(lib/perl);

use Test::More qw/no_plan/;

use Test::Darcs;
use Shell::Command;

use strict;

cleanup  'temp1';
mkpath 'temp1';
chdir  'temp1';
darcs 'init';

###

my $test_name = 'Make sure that messages about directories call them directories.';
mkpath 'foo.d';
mkpath 'oof.d';
darcs qw( add foo.d );
darcs qw( add oof.d );
# Try adding the same directory when it's already in the repo 
like(darcs(qw( add foo.d )), qr/directory/,$test_name);
like(darcs(qw( add foo.d oof.d )), qr/directories/,$test_name);

###

$test_name = 'Make sure that messages about files call them files.';
touch 'bar';
touch 'baz';
darcs qw( add bar ) ;
darcs qw( add baz ) ;
like(darcs(qw( add bar )), qr/following file is/, $test_name);
like(darcs(qw( add bar baz )), qr/following files are/, $test_name);

###

$test_name = 'Make sure that messages about both files and directories say so.';
like(darcs(qw( add bar foo.d )), qr/files and directories/, $test_name);

###

$test_name = 'Make sure that parent directories are added for files.';
mkpath 'a.d/aa.d/aaa.d';
mkpath 'b.d/bb.d';
touch 'a.d/aa.d/aaa.d/baz';
touch 'a.d/aa.d/aaa.d/bar';
like(darcs(qw( add a.d/aa.d/aaa.d/bar a.d/aa.d/aaa.d/baz b.d/bb.d )), qr/^$/, $test_name);
###

$test_name = 'Make sure that darcs doesn\'t complains about duplicate adds when adding parent dirs.';
mkpath 'c.d/';
touch 'c.d/baz';
like(darcs(qw( add c.d/baz c.d )), qr/^$/, $test_name);

###

$test_name = 'Make sure that add output looks good when adding files in subdir.';
mkpath 'd.d/';
touch 'd.d/foo';
like(darcs(qw(add -rv d.d)), qr/d.d\/foo/,$test_name);

TODO: {
    local $TODO = 'waiting on coding';
    my $test_name = "add should fail on files it can't read (because it would fail to record it later anyway).";
    touch "no_perms.txt";
    chmod(0000,"no_perms.txt");
    like(darcs(qw(add no_perms.txt)), qr/permission denied/,$test_name);
    rm_rf "no_perms.txt";

}


{
    my $test_name = 'adding a non-existent dir and file gives the expected message';
    my $out = darcs(qw!add notadir/notafile!);
    like($out,qr/does not exist/i,$test_name);
}


chdir '../';
cleanup 'temp1';
ok((!-d 'temp1'), 'temp1 directory was deleted');
