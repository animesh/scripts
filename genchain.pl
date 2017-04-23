#!/usr/bin/env perl

# generates SICHO chain
#
# http://mmtsb.scripps.edu/doc/genchain.pl.html
# 2000, Michael Feig, Brooks group, TSRI
#

sub usage {
  printf STDERR "usage:   genchain.pl [options] [[-m | -s | -pdb] file] | [-rnd num]\n";
  printf STDERR "options: [-r resolution] [-g gridsize]\n";
  printf STDERR "         [-float] [-center] [-ca]\n";
  printf STDERR "         [-o offsetx offsety offsetz]\n";
  printf STDERR "         [-l min:max[=min:max=...]]\n";
  printf STDERR "         [-setres num:name[,num:name]]\n";
  printf STDERR "         [-seq seqfile]\n";
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
use Sequence;
use SICHO;

my $resolution=1.45;
my $gridsize=100;
my $offsetx=50.0;
my $offsety=50.0;
my $offsetz=50.0;
my $fraglist;
my $mode="monsster";
my $filename="";
my $randomnum=-1;
my $center;
my $wantca=0;
my $intflag=1;
my $newresnames;
my $seqfile;

while ($#ARGV>=0) {
  if ($ARGV[0] eq "-help" || $ARGV[0] eq "-h") {
    &usage();
  } elsif ($ARGV[0] eq "-m") {
    shift @ARGV;
    $center=1 if (!defined $center);
    $mode="monsster";
  } elsif ($ARGV[0] eq "-rnd") {
    shift @ARGV;
    $center=1 if (!defined $center);
    $mode="random";
    $randomnum=shift @ARGV;
  } elsif ($ARGV[0] eq "-s") {
    shift @ARGV;
    $center=0 if (!defined $center);
    $mode="simple";
  } elsif ($ARGV[0] eq "-pdb") {
    shift @ARGV;
    $center=0 if (!defined $center);
    $mode="pdb";
    $resolution=0;
    $offsetx=$offsety=$offsetz=0;
  } elsif ($ARGV[0] eq "-r") {
    shift @ARGV;
    $resolution=shift @ARGV;
  } elsif ($ARGV[0] eq "-g") {
    shift @ARGV;
    $gridsize=shift @ARGV;
    $offsetx=$offsety=$offsetz=int($gridsize/2);
  } elsif ($ARGV[0] eq "-center") {
    shift @ARGV;
    $center=1;
  } elsif ($ARGV[0] eq "-nocenter") {
    shift @ARGV;
    $center=0;
  } elsif ($ARGV[0] eq "-float") {
    shift @ARGV;
    $intflag=0;
  } elsif ($ARGV[0] eq "-setres") {
    shift @ARGV;
    $newresnames=shift @ARGV;
  } elsif ($ARGV[0] eq "-seq") {
    shift @ARGV;
    $seqfile=shift @ARGV;
  } elsif ($ARGV[0] eq "-o") {
    shift @ARGV;
    $offsetx=shift @ARGV;
    $offsety=shift @ARGV;
    $offsetz=shift @ARGV;
  } elsif ($ARGV[0] eq "-l") {
    shift @ARGV;
    $fraglist=&GenUtil::fragListFromOption(shift @ARGV);
    $center=0;
  } elsif ($ARGV[0] eq "-ca") {
    shift @ARGV;
    $wantca=1;
  } elsif ($ARGV[0] =~/^-/) {
    printf STDERR "invalid option %s\n",shift @ARGV;
    &usage();
  } else {
    $filename=shift @ARGV;
  }    
}

if ($mode eq "none") {
  printf STDERR "Unknown mode: don't know what to do!\n";
  &usage();
}

my $sicho=SICHO::new(gridsize => $gridsize,
		     offsetx  => $offsetx,
		     offsety  => $offsety,
		     offsetz  => $offsetz,
		     resolution => $resolution,
		     intflag    => $intflag);
  
my $mol;
if ($mode eq "monsster") {
  $mol=Molecule::new();
  $mol->readPDB($filename);
  $mol->selectChain("");
  $mol->center() if ($center);
  $sicho->genMONSSTERFromAllAtom($mol, fraglist => $fraglist);
} elsif ($mode eq "random") {
  $sicho->genRandomMONSSTER($randomnum);  
} elsif ($mode eq "simple" || $mode eq "pdb") {
  $mol=Molecule::new();
  $mol->readPDB($filename);
  $mol->selectChain("");
  $mol->center() if ($center);
  $sicho->genSimpleFromAllAtom($mol,ca => $wantca);
}

if ($#{$sicho->{sidechain}}<0) {
  printf STDERR "Could not generate chain\n";
} else {
  if ($mode eq "pdb") {
    my $outmol=Molecule::new();
    my $seq;
    if (defined $seqfile) {
      $seq=Sequence::new();
      $seq->readMONSSTER($seqfile);
    } else {
      $seq=Sequence::new($mol);
      $seq->modifyResidueName($newresnames)
	if (defined $newresnames);
    }
    $outmol->fromSICHO($seq,$sicho);
    $outmol->writePDB(\*STDOUT,ssbond=>0);
  } else {
    $sicho->writeChain(\*STDOUT);
  }
}
