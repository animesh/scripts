#!/usr/bin/env perl

# Some tests for the --set-scripts-executable option.

use lib qw(lib/perl);
use Test::More qw/no_plan/;
use Test::Darcs;
use Shell::Command;
use strict;

if ($^O =~ /msys/i) {
    pass 'test does not work on windows';
} else {
    my $test_name = 'darcs pull --set-scripts-executable works';

    cleanup  'temp1';
    cleanup  'temp2';
    mkpath 'temp1';
    chdir 'temp1';
    darcs 'init';
    chdir '..';

    cp __FILE__, 'temp1/script.pl' || die $!;
    chmod 0644, 'temp1/script.pl' || die $!;
    system 'date > temp1/nonscript';
    ok( (-r 'temp1/script.pl'), 'pre test: script exists and is readable' );
    ok( ! (-x 'temp1/script.pl'), 'pre test: script is not executable' );
    ok( (-r 'temp1/nonscript'), 'pre test: nonscript exists and is readable' );
    ok( ! (-x 'temp1/nonscript'), 'pre test: nonscript is not executable' );

    chdir './temp1';  
    darcs  qw/add script.pl nonscript/;
    like( ( darcs qw!record --patch-name 'uno' --all --author foo\@bar! ), qr/finished recording/i );
    ok( chdir '..');
    # sans --set-scripts-executable (should not be executable)
    mkpath 'temp2';
    chdir 'temp2';
    darcs 'init';
    like( ( darcs qw%pull -a ../temp1 %) , qr/finished pulling/i );
    ok( (-r 'script.pl'), 'reality check: file has been pulled and is readable' );
    ok( (-r 'nonscript'), 'reality check: other file has been pulled and is readable' );

    ok(! (-x 'script.pl'), "nothing should be executable");
    ok(! (-x 'nonscript'), "nothing should be executable" );
    chdir '..';

    # darcs pull --set-scripts-executable
    `rm -rf temp2`;
    mkpath 'temp2';
    chdir 'temp2';
    darcs 'init';
    like( ( darcs qw%pull --set-scripts-executable -a ../temp1 %) ,
           qr/finished pulling/i );
    ok( (-r 'script.pl'), 'reality check: file has been pulled and is readable' );
    ok( (-r 'nonscript'), 'reality check: other file has been pulled and is readable' );

    ok( (-x 'script.pl'), $test_name );
    ok(! (-x 'nonscript'), "innocent bystanders aren't set to be executable" );
    chdir '../';     # now outside of any repo

    # now let's try the same thing with get
    `rm -rf temp2`;
    like( darcs('get --set-scripts-executable temp1 temp2') ,
           qr/finished/i );
    chdir 'temp2';
    ok( (-r 'script.pl'), 'reality check: file has been gotten and is readable' );
    ok( (-r 'nonscript'), 'reality check: other file has been gotten and is readable' );

    ok( (-x 'script.pl'), $test_name );
    ok(! (-x 'nonscript'), "innocent bystanders aren't set to be executable" );
    chdir '../';     # now outside of any repo

    ok(-d 'temp1', "temp1 exists here");
    cleanup 'temp1';
    ok((!-d 'temp1'), 'temp1 directory was deleted');

    ok(-d 'temp2', "temp2 exists here");
    cleanup 'temp2';
    ok((!-d 'temp2'), 'temp2 directory was deleted');

}




