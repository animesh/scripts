#!/usr/bin/env perl

# Some tests for 'darcs record '

use Test::More qw/no_plan/;
use lib ('lib/perl');
use Test::Darcs;
use strict;
use Shell::Command;
use Cwd;

cleanup  'temp1';
mkpath 'temp1';
chdir  'temp1';
darcs  'init';

###

if ($^O =~ /msys/i) {
    pass 'test does not work on msys due to stdin oddities';
} else {
    my $test_name = 'RT#476 - --ask-deps works when there are no patches';
    like( darcs(qw/record -A x -am foo --ask-deps/), qr/Finished recording/i,
          $test_name) ;
}

{
    my $test_name = 'RT#231 - special message is given for nonexistent directories';
    like( darcs(qw/record -A x -am foo not_there.txt/),qr/non ?existent/i, $test_name) ;
}

{
    my $test_name = 'RT#231 - a nonexistent file before an existing file is handled correctly';
    touch 'b.t';
    like( darcs(qw/record -A x -am foo a.t b.t/),
          qr/Non ?existent files or directories: "a.t"/i, $test_name) ;
}

{
    my $test_name = 'record works with absolute paths';

    touch 'date.t';
    darcs qw/add date.t/;

    like( darcs(qw!record -A x -a -m foo!, `pwd`."/date.t"), qr/Finished recording/i, $test_name);
}

TODO: {
    local $TODO = 'waiting on coding';
    my $test_name = "record should report all files with permissions problems, not just the first one. ";
    touch "no_perms.txt";
    touch "no_perms2.txt";
    darcs(qw/add no_perms.txt no_perms2.txt/); 
    chmod(0000,"no_perms.txt","no_perms2.txt");
    like(darcs("record -A x -a -m foo"), qr/perms.*perms2/,$test_name);
    cleanup "no_perms.txt", "no_perms2.txt";

}



BASIC_RECORD: {
    my $test_name = 'basic record';
    `date >> date.t`;
    like( darcs(qw/record -A x -a -m basic_record date.t/), qr/finished recording/i, $test_name);
}

LOGFILE: {
    my $test_name = 'testing --logfile';
    `date >> date.t`;
    `echo 'second record'>>log.txt`;
    like( darcs(qw/record -A x -a -m 'second record' --logfile=log.txt  date.t/), qr/finished recording/i, $test_name);

}

###

chdir '../';
cleanup 'temp1';
ok((!-d 'temp1'), 'temp1 directory was deleted');




