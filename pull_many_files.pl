#!/usr/bin/env perl

# Some tests for 'darcs unpull'

use lib qw(lib/perl);

use Test::More tests => 1101;
use Test::Darcs;
use Shell::Command;
use strict;

cleanup  'temp1';
mkpath 'temp1';
chdir  'temp1';
darcs 'init';
writefile("ALL --ignore-times", "_darcs/prefs/defaults");

touch 'foo';
darcs 'add foo';
darcs "record -A x -a -m 'adding foo' foo";

{ # Record lots of patches...
  my $how_many = 1100;
  my $n;
  for ($n=0;$n<$how_many;$n++) {
    writefile("$n\n", "foo");
    pass("still alive");
    darcs "record -A x -a -m 'change $n' foo";
  }
}

chdir '..';
cleanup 'temp2';
mkpath 'temp2';
chdir 'temp2';
darcs 'initialize';
like( darcs('pull -a ../temp1'),
      qr/Finished pulling/,
      "pull works on many patches at a time" );

####

chdir '../';
cleanup 'temp1';
cleanup 'temp2';


sub writefile {
  my ($contents, $filename) = @_;
  my $f;
  open($f, ">$filename") || die "Couldn't open $filename";
  print $f "$contents\n";
  close($f);
}
