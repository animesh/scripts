#!/usr/bin/env perl

# read DCD file
#
#

sub usage {
  printf STDERR "usage:    processDCD.pl [template] [dcdfile]\n";
  printf STDERR "options:  [-inx index[:to]] [-step n]\n";
  printf STDERR "          [-multi from:to]\n";
  printf STDERR "          [-apply cmd]\n";
  printf STDERR "          [-extract name]\n";
  printf STDERR "          [-ensdir dir] [-ens tag]\n";
  printf STDERR "          [-rms CA|CAB|C|O|N|side|back|all ... ref]\n";
  printf STDERR "          [-qscore ref] [-boxsize]\n";
  printf STDERR "          [-average] [-fit ref] [-fitsel cab|ca|cb|heavy] [-fitresnumonly]\n";
  printf STDERR "          [-psf file]\n";
  printf STDERR "          [-atoms from:to]\n";
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
use Ensemble;
use Analyze;


my $from=1;
my $to=99999999;
my $step=1;
my $pdbtemplate;
my $dcd;
my $apply;
my $rmsmode;
my $ref;
my $extract;
my $qscore;
my $avg=0;
my $psffile;
my $enstag;
my $ensdir=".";
my $multi;

my $frames;
my $atoms;

my $warn=1;
my $resnumonly=undef;

my $selmode="cab";

my $boxsize=0;

while ($#ARGV>=0) {
  if ($ARGV[0] eq "-inx") {
    shift @ARGV;
    my @f=split(/:/,shift @ARGV);
    $from=$f[0];
    $to=(defined $f[1])?$f[1]:$from;
    $frames=sprintf("%d-%d",$from,$to);
  } elsif ($ARGV[0] eq "-step") {
    shift @ARGV;
    $step=shift @ARGV;
  } elsif ($ARGV[0] eq "-apply") {
    shift @ARGV;
    $apply=shift @ARGV;
  } elsif ($ARGV[0] eq "-rms") {
    shift @ARGV;
    $rmsmode=shift @ARGV;
    $ref=shift @ARGV;
  } elsif ($ARGV[0] eq "-multi") {
    shift @ARGV;
    $multi=shift @ARGV;
  } elsif ($ARGV[0] eq "-ensdir") {
    shift @ARGV;
    $ensdir=shift @ARGV;
  } elsif ($ARGV[0] eq "-ens") {
    shift @ARGV;
    $enstag=shift @ARGV;
  } elsif ($ARGV[0] eq "-qscore") {
    shift @ARGV;
    $qscore=1;
    $ref=shift @ARGV;
  } elsif ($ARGV[0] eq "-psf") {
    shift @ARGV;
    $psffile=shift @ARGV;
  } elsif ($ARGV[0] eq "-average") {
    shift @ARGV;
    $avg=1;
  } elsif ($ARGV[0] eq "-boxsize") {
    shift @ARGV;
    $boxsize=1;
  } elsif ($ARGV[0] eq "-fit") {
    shift @ARGV;
    $ref=shift @ARGV;
  } elsif ($ARGV[0] eq "-fitsel") {
    shift @ARGV;
    $selmode=shift @ARGV;
  } elsif ($ARGV[0] eq "-fitresnumonly") {
    shift @ARGV;
    $resnumonly=1;
  } elsif ($ARGV[0] eq "-extract") {
    shift @ARGV;
    $extract=shift @ARGV;
  } elsif ($ARGV[0] eq "-help" || $ARGV[0] eq "-h") {
    &usage();
  } else {
    die "Unknown option $ARGV[0]" if ($ARGV[0]=~/^-/);
    $pdbtemplate=shift @ARGV unless (defined $psffile);
    $dcd=(shift @ARGV);
  }
}

my $nn=0;
my $mfrom=1;
my $mto=1;
if (defined $multi) {
  ($mfrom,$mto)=split(/:/,$multi);
}

my $fromframe=0;

my $at=-1;

my $ens;
    
if (defined $enstag) {
  $ens=Ensemble->new($enstag,$ensdir);
  $at=$ens->{par}->{runs}+1 if ($at<0);
} 

my $navg=0;
my $cmpmol;
my $avgmol;
my $refmol;
my $analyze;

if (defined $extract || $avg || defined $enstag) {
  $cmpmol=Molecule::new();
  if (defined $psffile) {
    $cmpmol->readPSF($psffile);
  } else {
    $cmpmol->readPDB($pdbtemplate);
  }

  if ($avg) {
    $avgmol=Molecule::new();
    if (defined $psffile) {
      $avgmol->readPSF($psffile);
    } else {
      $avgmol->readPDB($pdbtemplate);
    }
  }

  if (defined $ref) {
    $refmol=Molecule::new($ref);
    $analyze=Analyze::new($refmol);
  }

  foreach my $c ( @{$avgmol->{chain}} ) {
    foreach my $a ( @{$c->{atom}} ) {
      $a->{xcoor}=0.0;
      $a->{ycoor}=0.0;
      $a->{zcoor}=0.0;
    }
  }
}

my $i;

$from=1 if ($from<0);  #$nfiles+$from+1 if ($from<0);
$to=9999999 if ($to<0); # $nfiles+$to+1 if ($to<0);

my $itot=0;

for (my $im=$mfrom; $im<=$mto; $im++) {
  my $dcdfile;
  
  my $fdcd;
  if (defined $multi) {
    $fdcd=sprintf("$dcd",$im);
    printf STDERR "reading from %s\n",$fdcd;
  } else {
    $fdcd=$dcd;
  }

  $dcdfile=&GenUtil::getInputFile($fdcd);

  binmode $dcdfile;

  my $buffer;
  my $len;
  ($buffer,$len)=&readFortran($dcdfile);
  my ($tag,@icontrol)=unpack("A4L*",$buffer);
  
  ($buffer,$len)=&readFortran($dcdfile);
  ($buffer,$len)=&readFortran($dcdfile);
  my $natom=unpack("L",$buffer);
  
  my $tstep=unpack("f",pack("L",$icontrol[9]))*4.88882129E-02;
  my $nfiles=$icontrol[0];
  my $first=$icontrol[1];
  my $delta=$icontrol[2];
  my $deltat=$icontrol[2]*$tstep;
  my $crystal=$icontrol[10];
  my $fixed=$icontrol[8];

  my $firstframe=$first/$delta;

  my ($xbuf,$ybuf,$zbuf);

  if (defined $extract || $avg || defined $enstag || ($boxsize && $crystal)) {
    
    foreach my $c ( @{$cmpmol->{chain}} ) {
      foreach my $a ( @{$c->{atom}} ) {
	$a->{xcoor}=0.0;
	$a->{ycoor}=0.0;
	$a->{zcoor}=0.0;
      }
    }

    for ($i=1; $itot<=$to && $i<=$nfiles; $i++) {
      $itot++;
      
      if ($crystal) {
	my ($tbuf,$tlen)=&readFortran($dcdfile);
        if ($boxsize) {
          my @cdat=unpack("d*",$tbuf);
          printf "%f %f %f\n",$cdat[0],$cdat[2],$cdat[5];
        }
      }
      
      ($xbuf,$len)=&readFortran($dcdfile); # printf STDERR "%d ",$len;
      ($ybuf,$len)=&readFortran($dcdfile); # printf STDERR "%d ",$len;
      ($zbuf,$len)=&readFortran($dcdfile); # printf STDERR "%d \n",$len;
      
      if ($itot>=$from && $itot<=$to && ($itot%$step)==0 && !$boxsize) {
	my @xcoor=unpack("f*",$xbuf);
	my @ycoor=unpack("f*",$ybuf);
	my @zcoor=unpack("f*",$zbuf);

	my $start=0;
	foreach my $c ( @{$cmpmol->{chain}} ) {
	  foreach my $a ( @{$c->{atom}} ) {
	    $a->{xcoor}=$xcoor[$start];
	    $a->{ycoor}=$ycoor[$start];
	    $a->{zcoor}=$zcoor[$start];
	    $start++;
	  }
	}

	if (defined $refmol) {
	  $analyze->lsqfit($cmpmol,$selmode,$warn,$resnumonly);
	}
	
	if (!$avg) {
	  if (defined $enstag) {
	    $ens->checkinPDB($at++,$cmpmol,undef,"");
	  } else {
	    my $fname=sprintf("%s.%d.pdb",$extract,++$nn);
	    $cmpmol->writePDB($fname);
	  }
	} else {
	  for (my $ic=0; $ic<=$#{$cmpmol->{chain}}; $ic++) {
	    my $c=$cmpmol->{chain}->[$ic];
	    my $ac=$avgmol->{chain}->[$ic];
	    for (my $ia=0; $ia<=$#{$c->{atom}}; $ia++) {
	      $a=$c->{atom}->[$ia];
	      my $aa=$ac->{atom}->[$ia];
	      
	      $aa->{xcoor}+=$a->{xcoor};
	      $aa->{ycoor}+=$a->{ycoor};
	      $aa->{zcoor}+=$a->{zcoor};
	    }
	  }
	  
	  $navg++;
	}
      }
    }
  } elsif ((defined $rmsmode || defined $qscore) && defined $ref) {
    die "can apply rms/qscore command only for PDB files" 
      if (!defined $pdbtemplate && !defined $psffile);
    
    my $refmol=Molecule::new($ref);
    my $analyze=Analyze::new($refmol);
    my $cmpmol=Molecule::new();
    if (defined $psffile) {
      $cmpmol->readPSF($psffile);
    } else {
      $cmpmol->readPDB($pdbtemplate);
    }

    for ($i=1; $itot<=$to && $i<=$nfiles; $i++) {
      $itot++;

      printf STDERR "i: %d, itot: %d\n",$i,$itot;
      
      if ($crystal) {
	my ($tbuf,$tlen)=&readFortran($dcdfile);
      }
      
      ($xbuf,$len)=&readFortran($dcdfile); #printf STDERR "%d ",$len;
      ($ybuf,$len)=&readFortran($dcdfile); #printf STDERR "%d ",$len;
      ($zbuf,$len)=&readFortran($dcdfile); #printf STDERR "%d \n",$len;

      if ($itot>=$from && $itot<=$to && ($itot%$step)==0) {
	my @xcoor=unpack("f*",$xbuf);
	my @ycoor=unpack("f*",$ybuf);
	my @zcoor=unpack("f*",$zbuf);
      
	my $start=0;
	foreach my $c ( @{$cmpmol->{chain}} ) {
	  foreach my $a ( @{$c->{atom}} ) {
	    $a->{xcoor}=$xcoor[$start];
	    $a->{ycoor}=$ycoor[$start];
	    $a->{zcoor}=$zcoor[$start];
	    $start++;
	  }
	}
      
	if (defined $rmsmode) {
	  $analyze->lsqfit($cmpmol,"cab",0,1);
	  my $rmsd=$analyze->rmsd($cmpmol,0,undef,1);
	  
          printf "%d %f %f\n",($itot),($itot)*$deltat,$rmsd->{$rmsmode};
	} elsif (defined $qscore) {
	  my $qsc=$analyze->qscore($cmpmol,1);
	  printf "%d %f %f %f %f %f\n",($itot),($itot)*$deltat,
	    $qsc->{all},$qsc->{short},$qsc->{medium},$qsc->{long};
	}
      }
    }
  } else {
    my $cmpmol=Molecule::new();
    if (defined $psffile) {
      $cmpmol->readPSF($psffile);
    } else {
      $cmpmol->readPDB($pdbtemplate);
    }
    
    if (defined $apply) {
      die "can apply commands only for PDB files" 
	if (!defined $pdbtemplate && !defined $psffile);
      
      for ($i=1; $itot<=$to && $i<=$nfiles; $i++) {
	$itot++;

	if ($crystal) {
	  my ($tbuf,$tlen)=&readFortran($dcdfile);
	}
	
	($xbuf,$len)=&readFortran($dcdfile); #printf STDERR "%d ",$len;
	($ybuf,$len)=&readFortran($dcdfile); #printf STDERR "%d ",$len;
	($zbuf,$len)=&readFortran($dcdfile); #printf STDERR "%d \n",$len;

	if ($itot>=$from && $itot<=$to && ($itot%$step)==0) {	
	  my @xcoor=unpack("f*",$xbuf);
	  my @ycoor=unpack("f*",$ybuf);
	  my @zcoor=unpack("f*",$zbuf);
	
	  my $start=0;
	  foreach my $c ( @{$cmpmol->{chain}} ) {
	    foreach my $a ( @{$c->{atom}} ) {
	      $a->{xcoor}=$xcoor[$start];
	      $a->{ycoor}=$ycoor[$start];
	      $a->{zcoor}=$zcoor[$start];
	      $start++;
	    }
	  }
	  
	  $cmpmol->writePDB("tmp-$$");
	  printf "%d %1.4f ",($i+$firstframe-1),($i+$firstframe-1)*$deltat;
	  system "cat tmp-$$ | $apply";
	  &GenUtil::remove("tmp-$$");
	}
      }
    }
  }
}

$ens->save() if (defined $enstag);

if ($avg && $navg>0) {
  printf STDERR "navg: %d\n",$navg;
  foreach my $c ( @{$avgmol->{chain}} ) {
    foreach my $a ( @{$c->{atom}} ) {
      $a->{xcoor}/=$navg;
      $a->{ycoor}/=$navg;
      $a->{zcoor}/=$navg;
    }
  }
  $avgmol->writePDB();
}
  
1;



sub readFortran {
  my $handle=shift;

  my $dat;
  my $tdat;

  read($handle,$tdat,4) || die "cannot read data";
  my $len=unpack("L",$tdat);
  read($handle,$dat,$len) || die "cannot read data";
  read($handle,$tdat,4) || die "cannot read data";

#  printf STDERR "Fread %d bytes\n",$len;

  return ($dat,$len);
}

