#!/usr/bin/env perl

# tests for "darcs optimize"

use lib 'lib/perl';
use Test::More qw/no_plan/;
use strict;
use Test::Darcs;
use Shell::Command;

cleanup  'temp1';
mkpath 'temp1';
chdir 'temp1';

like( darcs('init'), qr/^$/i, 'initialized repo');

touch('foo');
darcs("add foo");
like( darcs("record -A x -a -m add_foo"), qr/finished recording/i, 'added patch');

like( darcs("optimize --modernize-patches"), qr/done optimizing/i, 
    "optimize --modernize-patches works for trivial case." );

like( darcs("optimize --reorder-patches"), qr/done optimizing/i, 
    "optimize --reorder-patches works for trivial case." );

chdir '../';
cleanup 'temp1';




