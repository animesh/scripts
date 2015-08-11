#!/usr/bin/perl -w

use lib 'lib/perl';

use Test::More 'no_plan';

use Test::Darcs;
use Shell::Command;
use File::Compare;

cleanup qw(temp1 temp2);
mkpath qw(temp1 temp2);
END { cleanup qw(temp1 temp2); }
chdir 'temp1';
darcs 'init';
mkpath 'dir';
ok( open FILE, ">dir/foo" ) || diag $!;
print FILE "zig";
close FILE;

darcs qw(add dir dir/foo);
darcs qw(record -a -m add_foo -A x);
chdir '../temp2';
darcs 'init';
darcs qw(pull -a ../temp1);
chdir '..';

ok compare(qw(temp1/dir/foo temp2/dir/foo)) == 0;
