#!/usr/bin/env perl

# Some tests for 'darcs whatsnew '

use lib 'lib/perl';
use Test::More qw/no_plan/;
use Shell::Command;
use Test::Darcs;
use strict;

cleanup 'temp1';
mkpath 'temp1';
chdir 'temp1';
darcs 'init';

my $testname = "issue70 and RT #349 - setpref should coalesce changes";
darcs 'setpref predist apple';
darcs 'setpref predist banana';
darcs 'setpref predist clementine';
darcs 'record -a -A me -m manamana'; 

unlike ( darcs('changes --verbose'), qr/apple/, $testname );
unlike ( darcs('changes --verbose'), qr/banana/, $testname );
like ( darcs('changes --verbose'), qr/clementine/, $testname );

chdir '../';
cleanup('temp1');

mkpath 'temp1';
chdir 'temp1';
darcs 'init';

# not sure what i'm going for here - if coalescing happens strictly
# before commuting, no problem, but what if patches are commuted 
# before coalescing?
$testname = "setpref should coalesce changes (nastier?)";
darcs 'setpref predist apple';
darcs 'setpref predist banana';
darcs 'setpref predist apple';
darcs 'setpref predist clementine';
darcs 'setpref predist banana';
darcs 'record -a -A me -m manamana'; 

unlike ( darcs('changes --verbose'), qr/apple/, $testname );
unlike ( darcs('changes --verbose'), qr/clementine/, $testname );
like ( darcs('changes --verbose'), qr/banana/, $testname );


chdir '../';
cleanup('temp1');
ok((!-d 'temp1'), 'temp1 directory was deleted');
