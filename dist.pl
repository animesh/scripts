#!/usr/bin/env perl

# tests for "darcs dist"

use lib 'lib/perl';
use Test::More qw/no_plan/;
use strict;
use Test::Darcs;
use Shell::Command;

cleanup 'temp1';
mkpath 'temp1';
chdir 'temp1';

like( darcs('init'), qr/^$/i, 'initialized repo');

touch('foo');
darcs("add foo");
like( darcs("record -A x -a -m add_foo"), qr/finished recording/i, 'added patch');

TODO: {
    local $TODO = "needs fixed on FreeBSD" if ($^O eq 'freebsd');
    unlike( darcs("dist -v"), qr/error/i, "darcs dist -v avoids error message " );
}


chdir '../';
cleanup 'temp1';




