#!/usr/bin/env perl

# Some tests for 'darcs unrecord'

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

TODO: {
    local $TODO =  'just noting we need real tests for these options';
    ok(0,'STUB: need real test for --from-match=PATTERN');
    ok(0,'STUB: need real test for --from-patch=REGEXP');   
    ok(0,'STUB: need real test for --from-tag=REGEXP');     
    ok(0,'STUB: need real test for --last=NUMBER');         
    ok(0,'STUB: need real test for --matches=PATTERN');
    ok(0,'STUB: need real test for --patches=REGEXP');      
}

####

chdir '../';
cleanup 'temp1';
ok((!-d 'temp1'), 'temp1 directory was deleted');
