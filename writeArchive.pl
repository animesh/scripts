#!/usr/bin/env perl

# write file to archive
#
# http://mmtsb.scripps.edu/doc/writeArchive.pl.html
# 2002, Michael Feig, Brooks group, TSRI
#

sub usage {
  printf STDERR "usage:    writeArchive.pl archivefile [file]\n";
  printf STDERR "options:  [-inx index]\n";
  printf STDERR "          [-pdb]\n";
  exit 1;
}

use vars qw ( $perllibdir );

BEGIN {
  $perllibdir="$ENV{MMTSBDIR}/perl" if (defined $ENV{MMTSBDIR});
  ($perllibdir=$0)=~s/[^\/]+$// if (!defined $perllibdir);
}

use lib $perllibdir;
use strict;

use GenUtil;

my $inx=9999999999;
my $pdbflag=0;
my $arfile;
my $file;

while ($#ARGV>=0) {
  if ($ARGV[0] eq "-inx") {
    shift @ARGV;
    $inx=shift @ARGV;
  } elsif ($ARGV[0] eq "-pdb") {
    shift @ARGV;
    $pdbflag=1;
  } elsif ($ARGV[0] eq "-help" || $ARGV[0] eq "-h") {
    &usage();
  } else {
    die "Unknown option $ARGV[0]" if ($ARGV[0]=~/^-/);
    $arfile=(shift @ARGV);
    $file=(shift @ARGV);
  }
}

if ($pdbflag) {
  my $all;
  my $pdb=&GenUtil::getInputFile($file);
  while (<$pdb>) {
    if (/ATOM/) {
      $all.=substr($_,30,24);
    }
  }
  undef $pdb;
  &GenUtil::writeArchiveFile($arfile,$all,$inx,1);
} else {
  &GenUtil::archiveFile($arfile,$file,$inx);
}
