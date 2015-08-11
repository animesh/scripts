#!/usr/bin/env perl

# replica exchange analysis
# 2002, 2004, 2006 Michael Feig, TSRI, MSU
#

sub usage {
  printf STDERR "usage:   rexanalysis.pl [options]\n";
  printf STDERR "options: [-dir workdir]\n";
  printf STDERR "         [-inx from:to] [-step value]\n";
  printf STDERR "         [-byclient clientid]\n";
  printf STDERR "         [-bytemp temp]\n";
  printf STDERR "         [-bycond condindex]\n";
  printf STDERR "         [-apply cmd]\n";
  printf STDERR "         [-function file]\n";
  printf STDERR "         [-wham prop:fname:from:to:nbins[=...]]\n";
  printf STDERR "         [-whamtemp temp[:temp2...]\n";
  printf STDERR "         [-whamener file]\n";
  exit 1;
}

use vars qw ( $perllibdir );

BEGIN {
  $perllibdir="$ENV{MMTSBDIR}/perl" if (defined $ENV{MMTSBDIR});
  ($perllibdir=$0)=~s/[^\/]+$// if (!defined $perllibdir);
}

use lib $perllibdir;
use strict;

use Math::Trig;

use GenUtil;
use Molecule;
use Ensemble;
use Sequence;
use ReXServer;
use Analyze;

my $dir=".";
my $condinx;
my $temp;
my $clientid;

my $from=1;
my $to=999999999;
my $step=1;

my $apply;
my $ffile;

my @wham=();
my @whamtemp=();
my $whamener;

while ($#ARGV>=0) {
  if ($ARGV[0] eq "-help" || $ARGV[0] eq "-h") {
    &usage();
  } elsif ($ARGV[0] eq "-dir") {
    shift @ARGV;
    $dir=shift @ARGV;
  } elsif ($ARGV[0] eq "-wham") {
    shift @ARGV;
    foreach my $w ( split(/=/,shift @ARGV) ) {
      my @fw=split(/:/,$w);
      my $trec={};
      $trec->{name}=$fw[0];
      $trec->{fname}=$fw[1];
      $trec->{min}=$fw[2];
      $trec->{max}=$fw[3];
      $trec->{nbins}=$fw[4];
      push(@wham,$trec);
    }
  } elsif ($ARGV[0] eq "-whamtemp") {
    shift @ARGV;
    push(@whamtemp,split(/:/,shift @ARGV));
  } elsif ($ARGV[0] eq "-whamener") {
    shift @ARGV;
    $whamener=shift @ARGV;
  } elsif ($ARGV[0] eq "-byclient") {
    shift @ARGV;
    $clientid=shift @ARGV;
  } elsif ($ARGV[0] eq "-bytemp") {
    shift @ARGV;
    $temp=shift @ARGV;
  } elsif ($ARGV[0] eq "-bycond") {
    shift @ARGV;
    $condinx=shift @ARGV;
  } elsif ($ARGV[0] eq "-step") {
    shift @ARGV;
    $step=shift @ARGV;
  } elsif ($ARGV[0] eq "-apply") {
    shift @ARGV;
    $apply=shift @ARGV;
  } elsif ($ARGV[0] eq "-function") {
    shift @ARGV;
    $ffile=shift @ARGV;
  } elsif ($ARGV[0] eq "-inx") {
    shift @ARGV;
    my @f=split(/:/,shift @ARGV);
    $from=$f[0];
    $to=($#f>0)?$f[1]:$f[0];
  } elsif ($ARGV[0]=~/^-/) {
    printf STDERR "unknown option %s\n",shift @ARGV;
    &usage();
  }
}

require "$ffile" if (defined $ffile);

$dir="." if (!defined $dir);

my $rex=ReXServer->new(0,$dir);
my $condfile=$dir."/rexserver.cond";
$rex->setup($condfile);
$rex->readData();

if ($#wham>=0) {
  printf STDERR "Preparing input files\n";

  foreach my $w ( @wham ) {
    die "cannot read $w->{fname}" if (!-r $w->{fname});

    my @out=();
    for (my $i=0; $i<=$#{$rex->{cond}}; $i++) {
      $out[$i]=&GenUtil::getOutputFile(sprintf("$$.%d.%s",$i,$w->{name}));
    }  
    
    open INP,"$w->{fname}";
    while (<INP>) {
      chomp;
      s/^\s+//g;
      my @f=split(/\s+/);
      for (my $i=0; $i<=$#{$rex->{cond}}; $i++) {
        my $oref=$out[$i];
	printf $oref "%s\n",$f[$i];
      }
    }
    close INP;

    for (my $i=0; $i<=$#{$rex->{cond}}; $i++) {
      my $oref=$out[$i];
      close $oref;
      undef $out[$i];
    }  
  }

  my @alltemps=();
  for (my $i=0; $i<=$#{$rex->{cond}}; $i++) {
    push(@alltemps,$rex->{cond}->[$i]->{temp});
  }
    
  if (defined $whamener && -r $whamener) {
    my @out=();
    for (my $i=0; $i<=$#{$rex->{cond}}; $i++) {
      $out[$i]=&GenUtil::getOutputFile(sprintf("$$.%d.ener",$i));
    }  
    
    open INP,$whamener;
    while (<INP>) {
      chomp;
      s/^\s+//g;
      my @f=split(/\s+/);
      for (my $i=0; $i<=$#{$rex->{cond}}; $i++) {
        my $oref=$out[$i];
	printf $oref "%s\n",$f[$i];
      }
    }
    close INP;

    for (my $i=0; $i<=$#{$rex->{cond}}; $i++) {
      my $oref=$out[$i];
      close $oref;
      undef $out[$i];
    }  
  } else {
    for (my $i=0; $i<=$#{$rex->{cond}}; $i++) {
      open OUT,sprintf(">$$.%d.ener",$i);
      for (my $ir=$from; $ir<=$rex->{trun} && $ir<=$to; $ir+=$step) {    
	my $c=$rex->getClientData(undef,$ir);      
	my $cdat;
	foreach my $cid (@{$rex->{clientid}}) {
	  if ($c->{$cid}->{cond}->{inx} == $condinx) {
	    $cdat=$c->{$cid};
	  }
	}
	my $ener=$cdat->{ener};
	printf OUT "%f\n",$ener;
      }
      close OUT;
    }
  }
  my @sortedtemps=sort { $a<=>$b } @alltemps;

  open OUT,">$$.flist";
  for (my $i=0; $i<=$#{$rex->{cond}}; $i++) {
    printf OUT "$$.%d.ener\n",$i;
    foreach my $w ( @wham ) {
      printf OUT "$$.%d.%s\n",$i,$w->{name};
    }
  }
  printf OUT "blab\n";
  close OUT;
  
  open OUT,">$$.whaminp";
  printf OUT "%s/rexserver.cond\n",$dir;
  printf OUT "%d\n",$#wham+1;
  printf OUT "$$.flist\n";
  printf OUT "50\n";
  foreach my $w ( @wham ) {
    printf OUT "%s\n",$w->{name};
    printf OUT "%f %f %d\n",$w->{min},$w->{max},$w->{nbins};
  }
  printf OUT "0\n$$.feout\n";
  printf OUT "%f %f 10\n",$sortedtemps[0],$sortedtemps[$#sortedtemps];

  push(@whamtemp,$sortedtemps[0]) if ($#whamtemp<0);
  
  printf OUT "%d\n",$#whamtemp+1;
  foreach my $wt ( @whamtemp ) {
    printf OUT "%f\n",$wt;
  }
  for (my $i=0; $i<$#wham; $i++) {
    for (my $j=$i+1; $j<=$#wham; $j++) {
      printf OUT "%s %s\n",$wham[$i]->{name},$wham[$j]->{name};
    }
  }
  close OUT;
  printf STDERR "Running WHAM\n";
  my $rexwhamexec=&GenUtil::findExecutable("rexwham");

  system("$rexwhamexec < $$.whaminp >& /dev/null");
  system("rm $$.*");
  
  printf STDERR "Done! Please check output files\n";
} else {
  die "need to specify command to apply" if (!defined $apply && !defined $ffile);
  
  if (defined $temp) {
    my $diff=1E99;
    for (my $i=0; $i <= $#{$rex->{cond}}; $i++) {
      if ((! defined $diff) || (abs($rex->{cond}->[$i]->{temp} - $temp) < $diff)) {
	$condinx=$i;
	$diff=abs($rex->{cond}->[$i]->{temp} - $temp);
      }
    }
  }
  
  my $mol=Molecule::new();
  if ($rex->{par}->{archive}) {
    $mol->readPDB(sprintf("%s/%s/final.pdb",$dir,$rex->{clientid}->[0]));
  }
  
  for (my $ir=$from; $ir<=$rex->{trun} && $ir<=$to; $ir+=$step) {
    my $c=$rex->getClientData(undef,$ir);

    my $cdat;
    my $scid;
    
    for (my $icond=0; $icond<=$#{$rex->{cond}}; $icond++) {
      if ((defined $clientid && $icond==0) || (!defined $condinx && !defined $clientid) || 
	  $icond==$condinx ) {
	
	if (defined $clientid) {
	  $scid=$clientid;
	  $cdat=$c->{$clientid};
	  die "cannot find data for client $clientid" if (!defined $cdat);
	} else { 
	  foreach my $cid (@{$rex->{clientid}}) {
	    if ($c->{$cid}->{cond}->{inx} == $icond) {
	      $scid=$cid;
	      $cdat=$c->{$cid};
	    }
	  }
	  die "cannot find data for condition $icond" if (!defined $cdat);
	}
    
	my $ener=$cdat->{ener};
	my $temp=$cdat->{cond}->{temp};
    
	my $dataok=1; 
	if ($rex->{par}->{archive}) {
	  my $arfile=sprintf("%s/%s/prod.coor.archive",$dir,$scid);
	  my $data=&GenUtil::readArchiveFile($arfile,$ir);
	  if (defined $data) {
	    my $start=0;
	    foreach my $c ( @{$mol->{chain}} ) {
	      foreach my $a ( @{$c->{atom}} ) {
		$a->{xcoor}=substr($data,$start,8)+0.0;
		$a->{ycoor}=substr($data,$start+8,8)+0.0;
		$a->{zcoor}=substr($data,$start+16,8)+0.0;
		$start+=24;
	      }
	    }
	  } else {
	    $dataok=0;
	  }
	} else {
	  my $pdbname=sprintf("%s/%s/prod/%s/final.pdb",$dir,$scid,&GenUtil::dataDir($ir));
	  if (-r $pdbname || -r "$pdbname.gz") {
	    $mol->readPDB($pdbname);
	  } else {
	    $dataok=0;
	  }
	}
    
	printf "%d %d %f %s ",$ir,$cdat->{cond}->{inx},$cdat->{cond}->{temp},$scid 
	  unless (!defined $clientid && !defined $condinx);

	if ($dataok) {
	  if (defined $ffile) {
	    my @res=&analyze($mol);
	    printf "%s ",join(" ",@res);
	    printf "\n" if (defined $clientid || defined $condinx);
	  } else {
	    open OUT,"|$apply";
	    $mol->writePDB(\*OUT);
	    close OUT;
	  }
	} else {
	  printf "data not found\n";
	}
      }
    }
    printf "\n" if (!defined $clientid && !defined $condinx);
  }
}

exit 0;

