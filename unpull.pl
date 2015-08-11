#!/usr/bin/env perl

# Some tests for 'darcs unpull'

use lib qw(lib/perl);

use Test::More qw/no_plan/;
use Test::Darcs;
use Shell::Command;
use strict;

cleanup  'temp1';
mkpath 'temp1';
chdir  'temp1';
darcs 'init';

touch qw/a.txt/;
darcs "add a.txt";
darcs "record -A x -a -m 'adding a' a.txt";

touch qw/b.txt/;
darcs "add b.txt";
darcs "record -A x -a -m 'adding b' b.txt";

like(
  echo_to_darcs("an","unpull -p add"),
  qr/really unpull/i, 
  "additional confirmation is given when 'all' option is selected");

like(
  echo_to_darcs("n","unpull --last 1"),
  qr/adding b/, 
  "unpull --last 1 gives expected result");


# Add a patch that depends on 'adding a' and try to unpull 'adding a'

`date >> a.txt`;
darcs "record -A x -a -m 'modifying a' a.txt";

like(
  echo_to_darcs("n","unpull -p 'adding a'"),
  qr/modifying a/ && qr/No patches selected/,
  "unpull asks about depending patches");

###

TODO: {
    local $TODO =  'just noting we need real tests for these options';
    ok(0,'STUB: need real test for --from-match=PATTERN');
    ok(0,'STUB: need real test for --from-patch=REGEXP');   
    ok(0,'STUB: need real test for --from-tag=REGEXP');     
    ok(0,'STUB: need real test for --matches=PATTERN');
    ok(0,'STUB: need real test for --patches=REGEXP');      
}




####

chdir '../';
cleanup 'temp1';
ok((!-d 'temp1'), 'temp1 directory was deleted');
