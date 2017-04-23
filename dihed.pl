#!/usr/bin/env perl

# compares dihedral distribution of a 
# protein structure compared to a reference structure
#
# http://mmtsb.scripps.edu/doc/dihed.pl.html
# 2001, Michael Feig, Brooks group, TSRI
#

sub usage {
  printf STDERR "usage:   dihed.pl [options] [refPDB [cmpPDB]]\n";
  printf STDERR "options: [-l min:max[...]]\n";
  printf STDERR "         [-list phi|psi|chi1|omega]\n";
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
use Molecule;
use Analyze;

my %list = { phi => 0,
	     psi => 0,
	     chi1 => 0,
             omega =>0 };

my $fraglist;
my $refpdb;

my $done=0;
while ($#ARGV>=0 && !$done) {
  if ($ARGV[0] eq "-help" || $ARGV[0] eq "-h") {
    &usage();
  } elsif ($ARGV[0] eq "-l") {
    shift @ARGV;
    $fraglist=&GenUtil::fragListFromOption(shift @ARGV);
  } elsif ($ARGV[0] eq "-list") {
    shift @ARGV;
    foreach my $tl ( split(/,/,shift @ARGV) ) {
      $list{$tl}=1;
    }
  } elsif ($ARGV[0] =~ /^-/) {
    printf STDERR "invalid option\n";
    &usage();
  } else {
    $refpdb = shift @ARGV;
    $done=1;
  }
}

my $analyze;

if ($list{phi} || $list{psi} || $list{chi1} || $list{omega}) {
  my $mol=Molecule::new();
  $mol->readPDB($refpdb);
  $mol->setValidResidues($fraglist,0)
    if (defined $fraglist);

  &Analyze::phipsi($mol) if ($list{phi} || $list{psi} || $list{omega});
  &Analyze::chi1($mol) if ($list{chi1});

  foreach my $c ( @{$mol->activeChains()} ) {
    foreach my $r ( @{$c->{res}} ) {
      if ($r->{valid}) {
	printf "%s%d:%s",$r->{name},$r->{num},$r->{chain};
	printf " %8.3f",$r->{phi}  if ($list{phi});
	printf " %8.3f",$r->{psi}  if ($list{psi});
	printf " %8.3f",$r->{omega}  if ($list{omega});
	printf " %8.3f",$r->{chi1} if ($list{chi1});
	printf "\n";
      }
    }
  }
} else {
  my $refmol=Molecule::new();
  $refmol->readPDB($refpdb);
  $analyze=Analyze::new($refmol);

  my $mol=Molecule::new();
  $mol->readPDB(shift @ARGV);
  $mol->setValidResidues($fraglist,0)
    if (defined $fraglist);

  my ($phi,$psi,$cphi,$cpsi)=$analyze->phipsiRMSD($mol);
  my ($chi1,$cchi1)=$analyze->chi1RMSD($mol);

  printf STDOUT "phi: %1.3f ( %1.2f \% ), psi: %1.3f ( %1.2f \% ), chi1: %1.3f ( %1.2f \% )\n",
  $phi,$cphi,$psi,$cpsi,$chi1,$cchi1;
}  
