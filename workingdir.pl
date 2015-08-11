#!/usr/bin/env perl

# test for working dir woes

use Test::More qw/no_plan/;
use lib ('lib/perl');
use Test::Darcs;
use strict;
use Cwd;

sub reset_chmod {
  my $d = shift;
  `chmod -R u+w $d` if (-d $d);
}

# note that we deliberately choose something other than temp
# so as to avoid interfering with other tests if something
# goes wrong and we fail to reset the permissions.
reset_chmod('wtemp0');
reset_chmod('wtemp1');
reset_chmod('wtemp2');

cleanup 'wtemp0';
cleanup 'wtemp1';
cleanup 'wtemp2';
mkdir 'wtemp0';
chdir 'wtemp0';
darcs 'init';
mkdir 'a';
`touch a/x`;
darcs 'add a';
darcs 'add a/x';
darcs 'record -am "a" --author me';
chdir '..';

darcs 'get wtemp0 wtemp1';
darcs 'get wtemp1 wtemp2';
chdir 'wtemp1';
darcs 'mv a/x a/y';
darcs 'record -am "x to y" --author me';
`touch b`;
darcs 'add b';
darcs 'record -am "b" --author me';
chdir '../wtemp2';
# try to move a file that we don't have the right to do
`chmod u-w a`;
darcs 'pull -a';
ok((-e 'b'), "managed to do pull b despite problems with x to y");
chdir '..';


reset_chmod('wtemp0');
reset_chmod('wtemp1');
reset_chmod('wtemp2');
cleanup('wtemp0');
cleanup('wtemp1');
cleanup('wtemp2');
