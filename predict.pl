#!/usr/bin/env perl
#
# structure prediction and refinement
#
# http://mmtsb.scripps.edu/doc/predict.pl.html
# 2001, Michael Feig, Brooks group, TSRI
#

sub usage {
  printf STDERR "usage:   predict.pl [options] [file(s)]\n";
  printf STDERR "options: [-f file]\n";
  printf STDERR "         [-verbose]\n";
  printf STDERR "         [-cpus num] [-hosts hostfile]\n";
  printf STDERR "         [-mp] [-keepmpdir]\n";
  printf STDERR "         [-l refPDB min:max[=min:max...]]\n";
  printf STDERR "         [-seqfile file]\n";
  printf STDERR "         [-seq abbrev] [-2nd file[:file...]]\n";
  printf STDERR "         [-lseq inx abbrev]\n";
  printf STDERR "         [-latrex]\n";
  printf STDERR "         [-latrexpar runs=value,ncycle=value,\n";
  printf STDERR "                     stiff=value,short=value,\n";
  printf STDERR "                     central=value]\n";
  printf STDERR "         [-minpar steps=value,tol=value,param=value,\n";
  printf STDERR "                  solvent=value,cutnb=value,\n";
  printf STDERR "                  cutoff=value,cuton=value]\n";
  printf STDERR "         [-aarex]\n";
  printf STDERR "         [-aarexpar runs=value,steps=value,param=value,\n";
  printf STDERR "                    solvent=value,cutnb=value,\n";
  printf STDERR "                    cutoff=value,cuton=value\n";
  printf STDERR "                    mintemp=value,maxtemp=value]\n";
  printf STDERR "         [-finalmin]\n";
  printf STDERR "         [-fminpar steps=value,tol=value,param=value,\n";
  printf STDERR "                   solvent=value,cutnb=value,\n";
  printf STDERR "                   cutoff=value,cuton=value]\n";
  exit 1;
}

require 5.004;

use vars qw ( $perllibdir );

BEGIN {
  $perllibdir="$ENV{MMTSBDIR}/perl" if (defined $ENV{MMTSBDIR});
  ($perllibdir=$0)=~s/[^\/]+$// if (!defined $perllibdir);
}

use lib $perllibdir;
use strict;

use Sys::Hostname;

use GenUtil;
use Molecule;
use Sequence;
use Cluster;
use Ensemble;

my $hostfile;
my $cpus=1;
my $seqfile;

my %latrexpar = (
  runs    => undef,
  ncycle  => undef,
  stiff   => undef,
  short   => undef,
  central => undef,
  mintemp => 1.0,
  maxtemp => undef
);

my %aarexpar = ( 
  runs    => undef,
  steps   => undef,
  tol     => undef,
  param   => undef,
  solvent => undef,
  cutnb   => undef,
  cutoff  => undef,
  cuton   => undef,
  mintemp => undef,
  maxtemp => undef
);

my %minpar = ( 
  steps   => undef,
  tol     => undef,
  param   => undef,
  solvent => undef,
  cutnb   => undef,
  cutoff  => undef,
  cuton   => undef
);

my %fminpar = ( 
  steps   => undef,
  tol     => undef,
  param   => undef,
  solvent => undef,
  cutnb   => undef,
  cutoff  => undef,
  cuton   => undef
);

my $latrex;
my $aarex;
my $finalmin;

my $fragrefpdb;
my $fraglistoption;

my $listfile;
my $inpfilelist=();

my $slist=();
my $seqabbrev;
my $pred2ndfiles=();

my $cons=();

my $mp=0;
my $keepmpdir=0;

while ($#ARGV>=0) {
  if ($ARGV[0] eq "-help" || $ARGV[0] eq "-h") {
    &usage();
  } elsif ($ARGV[0] eq "-f") {
    shift @ARGV;
    $listfile=shift @ARGV;
  } elsif ($ARGV[0] eq "-cpus") {
    shift @ARGV;
    $cpus=shift @ARGV;
  } elsif ($ARGV[0] eq "-hosts") {
    shift @ARGV;
    $hostfile=shift @ARGV;
  } elsif ($ARGV[0] eq "-mp") {
    shift @ARGV;
    $mp=1;
  } elsif ($ARGV[0] eq "-keepmpdir") {
    shift @ARGV;
    $keepmpdir=1;
  } elsif ($ARGV[0] eq "-latrexpar") {
    shift @ARGV;
    foreach my $p ( split(/,/,shift @ARGV) ) {
      my ($key,$val)=split(/=/,$p);
      $latrexpar{$key}=(defined $val)?$val:1;
    }
    $latrex=1;
  } elsif ($ARGV[0] eq "-aarexpar") {
    shift @ARGV;
    foreach my $p ( split(/,/,shift @ARGV) ) {
      my ($key,$val)=split(/=/,$p);
      $aarexpar{$key}=(defined $val)?$val:1;
    }
    $aarex=1;
  } elsif ($ARGV[0] eq "-minpar") {
    shift @ARGV;
    foreach my $p ( split(/,/,shift @ARGV) ) {
      my ($key,$val)=split(/=/,$p);
      $minpar{$key}=(defined $val)?$val:1;
    }
  } elsif ($ARGV[0] eq "-fminpar") {
    shift @ARGV;
    foreach my $p ( split(/,/,shift @ARGV) ) {
      my ($key,$val)=split(/=/,$p);
      $fminpar{$key}=(defined $val)?$val:1;
    }
    $finalmin=1;
  } elsif ($ARGV[0] eq "-l") {
    shift @ARGV;
    $fragrefpdb=shift @ARGV;
    $fraglistoption=shift @ARGV;
  } elsif ($ARGV[0] eq "-lseq") {
    shift @ARGV;
    my $srec={};
    $srec->{inx}=shift @ARGV;
    $srec->{seq}=shift @ARGV;
    push(@{$slist},$srec);
  } elsif ($ARGV[0] eq "-verbose") {
    shift @ARGV;
    &GenUtil::setLogFile("-");
  } elsif ($ARGV[0] eq "-latrex") {
    shift @ARGV;
    $latrex=1;
  } elsif ($ARGV[0] eq "-aarex") {
    shift @ARGV;
    $aarex=1;
  } elsif ($ARGV[0] eq "-finalmin") {
    shift @ARGV;
    $finalmin=1;
  } elsif ($ARGV[0] eq "-seqfile") {
    shift @ARGV;
    $seqfile=shift @ARGV;
  } elsif ($ARGV[0] eq "-seq") {
    shift @ARGV;
    $seqabbrev=shift @ARGV;
  } elsif ($ARGV[0] eq "-2nd") {
    shift @ARGV;
    @{$pred2ndfiles}=split(/:/,shift @ARGV);
  } elsif ($ARGV[0] =~/^-/) {
    printf STDERR "invalid option %s\n",shift @ARGV;
    &usage();
  } else {
    my $rec={};
    $rec->{name}=shift @ARGV;
    push (@{$inpfilelist},$rec);
  }    
}

if (defined $listfile && &GenUtil::checkFile($listfile) ) {
  my $f=&GenUtil::getInputFile($listfile);
  while (<$f>) {
    chomp;
    my $rec={};
    $rec->{name}=$_;
    push(@{$inpfilelist},$rec)
      if (&GenUtil::checkFile($_));
  }
  undef $f;
}

if ($#{$inpfilelist}>=0) {
  &GenUtil::log("predict","running structure refinement");
} else {
  &GenUtil::log("predict","running ab initio prediction");
}

&GenUtil::log("predict","loop/fragment modeling for residues $fraglistoption")
  if (defined $fraglistoption);

my $sortedfiles;
my $optfile;

if ((defined $latrex && $latrex) || $#{$inpfilelist}<0) {
  if (!-r "one.done") {
    my $inpflistname=&genListFile($inpfilelist,$cpus);
    
    $seqfile=&autoSeqFile($seqabbrev,$pred2ndfiles,
			  ($#{$inpfilelist}>=0)?$inpfilelist->[0]:$fragrefpdb,
			  $slist) 
      if (!defined $seqfile);
    
    &runlatrex("one","latrex",\%latrexpar,$seqfile,$fragrefpdb,$fraglistoption,
	       $inpflistname,$cpus,$hostfile,$mp);

    die "lattice replica exchange not complete"
      if (&ensruns("one","latrex")<$latrexpar{runs});

    if (defined $fraglistoption) {
      push(@{$cons},&runenscut("one","latrex","cut",$fragrefpdb,$fraglistoption));
      &runensmin("one","cut","min",\%minpar,$cpus,$hostfile,$mp,$cons);
    } else {
      &runensmin("one","latrex","min",\%minpar,$cpus,$hostfile,$mp,$cons);
    }

    die "minimization not complete"
      if (&ensruns("one","min")<$latrexpar{runs});

    &runcluster("one","min",$latrexpar{runs});

    die "clustering not complete"
      if (!-r "one/min.cluster");

    system "touch one.done";
  }
  $sortedfiles=&bestcluster("one","min",0,$cpus,0.3);
} else {
  if (!-r "one.done") {
    &checkin("one","init",$inpfilelist);
    if (defined $fraglistoption) {
      push(@{$cons},&runenscut("one","init","cut",$fragrefpdb,$fraglistoption));
      &runensmin("one","cut","min",\%minpar,$cpus,$hostfile,$mp,$cons);
    } else {
      &runensmin("one","init","min",\%minpar,$cpus,$hostfile,$mp,$cons);
    }

    die "minimization not complete"
      if (&ensruns("one","min")<$latrexpar{runs});
    
    system "touch one.done";
  }

  $sortedfiles=&ensfiles("one","min");
}

if ((defined $aarex && $aarex) && $#{$sortedfiles}>=0) {
  if (!-r "two.done") {
    foreach my $n ( @{$sortedfiles} ) {
      &GenUtil::log("predict","stage two input file $n->{name}, energy: $n->{val}");
    }
  
    my $aainpname=&genListFile($sortedfiles,$cpus);
    
    &runaarex("two","aarex",\%aarexpar,$aainpname,$cpus,$hostfile,$mp,$cons);

    die "all-atom replica exchange not complete"
      if (&ensruns("two","aarex")<$aarexpar{runs});
    
    &runcluster("two","aarex",$aarexpar{runs});

    die "clustering not complete"
      if (!-r "two/aarex.cluster");

    system "touch two.done";
  }
  
  $sortedfiles=&bestcluster("two","aarex",1,10,0.0);
}

if ($finalmin && $#{$sortedfiles}>=0) {
  if (!-r "three.done") {
    &checkin("three","res",$sortedfiles);
    if (defined $fraglistoption) {
      &merge("three","res","resmerge",$fragrefpdb,$cpus,$hostfile,$mp);
      &runensmin("three","resmerge","resmin",\%fminpar,$cpus,$hostfile,$mp,$cons);
    } else {
      &runensmin("three","res","resmin",\%fminpar,$cpus,$hostfile,$mp,$cons);
    }

    die "minimization not complete"
      if (&ensruns("three","resmin")<$#{$sortedfiles}+1);

    &GenUtil::log("predict","all done");

    system "touch three.done";
  }
  &GenUtil::log("predict","result:");
  $sortedfiles=&ensfiles("three","resmin");
} 

foreach my $f ( @{$sortedfiles} ) {
  printf STDOUT "%s %f\n",$f->{name},$f->{val};
}

exit 0;

## genListFile ######

sub genListFile {
  my $list=shift;
  my $cpus=shift;

  my $fname;

  my $ninp=$#{$list}+1;
  if ($ninp>0) {
    $fname="input.files";
    my $ifhandle=&GenUtil::getOutputFile($fname);
    foreach my $if ( @{$list} ) {
      print $ifhandle $if->{name},"\n";
    }
    for (my $i=0; $i<$cpus-$ninp; $i++) {
      print $ifhandle $list->[$i]->{name},"\n";
    }
    close $ifhandle;
  }
  return $fname;
}

## autoSeqFile ######

sub autoSeqFile {
  my $seqabbrev=shift;
  my $pred2ndfiles=shift;
  my $pdb=shift;
  my $slist=shift;

  my $seqfile;

  if (defined $seqabbrev) {
    my $seq=Sequence::new($seqabbrev);
    if ($#{$pred2ndfiles}>=0) {
      $seq->secFromPredict(@{$pred2ndfiles});
    }
    $seqfile="abbrev.seq";
    $seq->writeMONSSTER($seqfile);
    &GenUtil::log("predict","automatically generated sequence file $seqfile from input sequence");
  } elsif (defined $pdb) {
    my $mol=Molecule::new();
    $mol->readPDB($pdb);
    my $seq;
    if (defined $slist && $#{$slist}>=0) {
      $seq=Sequence::new($mol,$slist);
      $seqfile="fragref.seq";
    } else {
      $seq=Sequence::new($mol);
      $seq->secFromDSSP($mol);
      $seqfile="inpfile.seq";
    }      
    $seq->writeMONSSTER($seqfile);
    &GenUtil::log("predict","automatically generated sequence file $seqfile from $pdb");
  }
  return $seqfile;
}

## runlatrex ######

sub runlatrex {
  my $ensdir=shift;
  my $tag=shift;
  my $par=shift;
  my $seqfile=shift;
  my $fragrefpdb=shift;
  my $fraglistoption=shift;
  my $inpflistname=shift;
  my $cpus=shift;
  my $hostfile=shift;
  my $mp=shift;

  die "sequence file required for running lattice simulations"
    if (!defined $seqfile);

  die "replica exchange requires at least 4 CPUs\n" 
    if ($cpus<4);

  $par->{runs}=1000 if (!defined $par->{runs});

  $par->{stiff}=(!defined $inpflistname && !defined $fraglistoption)?1.25:0.8
    if (!defined $par->{stiff});
  $par->{short}=(!defined $inpflistname && !defined $fraglistoption)?0.5:0.35
    if (!defined $par->{short});
  $par->{central}=(!defined $inpflistname && !defined $fraglistoption)?0.5:0.2
    if (!defined $par->{central});
  $par->{ncycle}=(defined $fraglistoption)?5:10
    if (!defined $par->{ncycle});

  $par->{maxtemp}=(!defined $inpflistname)?2.0:1.6
    if (!defined $par->{maxtemp});
  
  my $initruns=int($par->{runs}/20);
  $initruns=10 if ($initruns>10);
  $initruns=1 if ($initruns<1);

  my $equilruns=int($par->{runs}/10);
  $equilruns=20 if ($equilruns>20);
  $equilruns=1 if ($equilruns<1);

  my $options="";
  $options.="-n -$par->{runs} -dir $tag ";          
  $options.="-f $inpflistname -input pdb " if (defined $inpflistname);
  $options.="-par initruns=$initruns,equilruns=$equilruns,nosave,norebuild,seq=$seqfile ";
  $options.="-temp $cpus:$par->{mintemp}:$par->{maxtemp} ";
  $options.="-ens $tag -ensdir $ensdir ";
  $options.="-hosts $hostfile " if (defined $hostfile);
  $options.="-mp " if ($mp);
  $options.="-keepmpdir " if ($keepmpdir);
  $options.="-l $fragrefpdb $fraglistoption -simopt limforce=2.0 "
    if (defined $fraglistoption);
  $options.="-simpar ncycle=$par->{ncycle},icycle=50,stiff=$par->{stiff},short=$par->{short},central=$par->{central} ";
  
  &GenUtil::log("predict",
   "replica exchange lattice simulation: $par->{runs} runs, $cpus windows, $par->{ncycle} cycles");
  &GenUtil::log("predict","  calling latrex.pl $options");

  system "rm -r $tag" if (-d $tag);
  system "latrex.pl $options";
}

## runaarex ######

sub runaarex {
  my $ensdir=shift;
  my $tag=shift;
  my $par=shift;
  my $inpflistname=shift;
  my $cpus=shift;
  my $hostfile=shift;
  my $mp=shift;
  my $cons=shift;

  die "replica exchange requires at least 4 CPUs" 
    if ($cpus<4);

  die "need input files for all-atom replica exchange" 
    if (!defined $inpflistname || $inpflistname eq "");

  $par->{runs}=100 if (!defined $par->{runs});

  $par->{steps}=300    if (!defined $par->{steps});
  $par->{tol}=1E-5     if (!defined $par->{tol});
  $par->{param}=19     if (!defined $par->{param});
  $par->{solvent}="gb" if (!defined $par->{solvent});
  $par->{cutnb}=20     if (!defined $par->{cutnb});
  $par->{cutoff}=16    if (!defined $par->{cutoff});
  $par->{cuton}=16     if (!defined $par->{cuton});

  $par->{maxtemp}=500.0 if (!defined $par->{maxtemp});
  $par->{mintemp}=298.0 if (!defined $par->{mintemp});

  my $initruns=int($par->{runs}/20);
  $initruns=10 if ($initruns>10);
  $initruns=1 if ($initruns<1);

  my $equilruns=int($par->{runs}/10);
  $equilruns=20 if ($equilruns>20);
  $equilruns=1 if ($equilruns<1);

  my $options="";
  $options.="-n -$par->{runs} -dir $tag ";          
  $options.="-f $inpflistname ";
  $options.="-par initruns=$initruns,equilruns=$equilruns,nosave ";
  $options.="-temp $cpus:$par->{mintemp}:$par->{maxtemp} ";
  $options.="-ens $tag -ensdir $ensdir ";
  $options.="-hosts $hostfile " if (defined $hostfile);
  $options.="-mp " if ($mp);
  $options.="-keepmpdir " if ($keepmpdir);
  $options.="-mdpar steps=$par->{steps},tol=$par->{tol},param=$par->{param},$par->{solvent},cutnb=$par->{cutnb},cutoff=$par->{cutoff},cuton=$par->{cuton} ";
  $options.="-mdopt notrajout ";
  if ($#{$cons}>=0) {
    foreach my $c ( @{$cons} ) {
      $options.="-cons $c->{sel} $c->{ref} $c->{list} ";
    }
  }
  
  &GenUtil::log("predict",
   "replica exchange all-atom simulation: $par->{runs} runs, $cpus windows, $par->{steps} steps");
  &GenUtil::log("predict","  calling aarex.pl $options");

  system "aarex.pl $options";
}


## runensmin ######

sub runensmin {
  my $ensdir=shift;
  my $intag=shift;
  my $outtag=shift;
  my $par=shift;
  my $cpus=shift;
  my $hostfile=shift;
  my $mp=shift;
  my $cons=shift;

  $par->{steps}=300    if (!defined $par->{steps});
  $par->{tol}=1E-5     if (!defined $par->{tol});
  $par->{param}=19     if (!defined $par->{param});
  $par->{solvent}="gb" if (!defined $par->{solvent});
  $par->{cutnb}=20     if (!defined $par->{cutnb});
  $par->{cutoff}=16    if (!defined $par->{cutoff});
  $par->{cuton}=16     if (!defined $par->{cuton});

  my $options="";
  $options.="-dir $ensdir ";
  $options.="-cpus $cpus ";
  $options.="-hosts $hostfile " if (defined $hostfile);
  $options.="-mp " if ($mp);
  $options.="-keepmpdir " if ($keepmpdir);
  $options.="-par steps=$par->{steps},tol=$par->{tol},param=$par->{param},$par->{solvent},cutnb=$par->{cutnb},cutoff=$par->{cutoff},cuton=$par->{cuton} ";
  if ($#{$cons}>=0) {
    $options.="-finalrest ";
    foreach my $c ( @{$cons} ) {
      $options.="-cons $c->{sel} $c->{ref} $c->{list} ";
    }
  }

  $options.="$intag $outtag";

  &GenUtil::log("predict","minimizing $intag -> $outtag");
  &GenUtil::log("predict","  calling ensmin.pl $options");  

  system "ensmin.pl $options";
}

## runenscut ######

sub runenscut {
  my $ensdir=shift;
  my $intag=shift;
  my $outtag=shift;
  my $fragrefpdb=shift;
  my $fraglistoption=shift;
  
  my $hardcutoff=16.0;
  my $softcutoff=10.0;

  my $options="-dir $ensdir ";
  $options.="-l $fraglistoption " if (defined $fraglistoption);
  $options.="-hard $hardcutoff -soft $softcutoff ";
  $options.="$intag $outtag";

  &GenUtil::log("predict","cutting out residues around fragment list");
  &GenUtil::log("predict","  calling enscut.pl $options");

  system "enscut.pl $options";

  my $ens=Ensemble->new($outtag,$ensdir);  
  my @cstr=split(/,/,$ens->{opt}->{cons});
  my $c={ sel=>$cstr[0], list=>$cstr[2], ref=>$fragrefpdb };

  return $c;
}

## runcluster ######

sub runcluster {
  my $ensdir=shift;
  my $tag=shift;
  my $runs=shift;

  my $clustermaxnum=5;
  my $clusterminsize=$runs/$clustermaxnum;
  if ($clusterminsize<10) {
    $clusterminsize=($runs>10)?10:$runs;
  }

  my $options="";
  $options.="-dir $ensdir -mode rmsd ";
  $options.="-maxnum $clustermaxnum -minsize $clusterminsize ";
  $options.="$tag";

  &GenUtil::log("predict","cluster $tag");
  &GenUtil::log("predict","  calling enscluster.pl $options");
  system "enscluster.pl $options";
}

## bestcluster ######

sub bestcluster {  
  my $ensdir=shift;
  my $tag=shift;
  my $size=shift;
  my $best=shift;
  my $fraction=shift;

  $best=10 if (!defined $best);

  my $ens=Ensemble->new($tag,$ensdir);
  my $cluster=Cluster::new();

  die "no clusters available"
    if (!-r "$ens->{dir}/$ens->{tag}.cluster");

  $cluster->readFile("$ens->{dir}/$ens->{tag}.cluster");
  
  my $clist=$cluster->clusterList(-1);

  die "no clusters found"
    if (!defined $clist || $#{$clist}<0);

  my $ntot=0.0;
  my $res=();
  foreach my $c ( @{$clist} ) {
    my $plist=$ens->getPropList("etot",$c->{element});
    my $rec={};
    my $olist=();
    my $lastlimit;
    ($olist,$lastlimit,$rec->{score},$rec->{sdev},$rec->{nscore})=
      &GenUtil::limCore($plist,lower=>0,upper=>1,mult=>3.0);
    $rec->{cluster}=$c;
    $rec->{size}=$#{$c->{element}}+1;
    push (@{$res},$rec);
    $ntot+=$rec->{size};
  }

  my @slist;

  if ($size) {
    @slist=sort { $b->{size} <=> $a->{size} || $a->{score} <=> $b->{score} } @{$res};
  } else {
    @slist=sort { $a->{score} <=> $b->{score} } @{$res};
  }
  
  my @inclList=();
  my $pnum=0;
  foreach my $s ( @slist ) {
    if ($pnum<=int($ntot*$fraction)) {
      my $slist=$ens->getSortedList("etot",$s->{cluster}->{element});
      push(@inclList,$slist);
    }
    $pnum+=$s->{size};
  }

  my $flist=();
  for (my $inx=0; $inx<$best; $inx++) {
    foreach my $i (@inclList) {
      if ($inx<=$#{$i}) {
	my $rec={};
	$rec->{name}=$i->[$inx]->{name};
	$rec->{val}=$i->[$inx]->{val};
	push(@{$flist},$rec);
      }
    }
  }

  return $flist;
}

## checkin ######

sub checkin {
  my $ensdir=shift;
  my $tag=shift;
  my $list=shift;

  my $ens=Ensemble->new($tag,$ensdir);
  
  my $at=1;
  foreach my $f ( @{$list} ) {
    $ens->setFileList($at,$f->{name});
    my $mol=Molecule::new($f->{name});
    $ens->checkinPDB($at++,$mol);
  }
    
  $ens->save();
}

## ensfiles ######

sub ensfiles {
  my $ensdir=shift;
  my $tag=shift;

  my $ens=Ensemble->new($tag,$ensdir);
  return $ens->getSortedList("etot",$ens->fileList());
}

## merge ######

sub merge {
  my $ensdir=shift;
  my $intag=shift;
  my $outtag=shift;
  my $fragref=shift;
  my $cpus=shift;
  my $hostfile=shift;
  my $mp=shift;

  my $refpdb=$fragref;
  if (substr($refpdb,0,1) ne '/') {
    my $pwd=$ENV{PWD};
    chomp $pwd;
    $refpdb=$pwd."/".$refpdb;
  }

  my $options="";
  $options.="-dir $ensdir ";
  $options.="-cpus $cpus ";
  $options.="-hosts $hostfile " if (defined $hostfile);
  $options.="-mp " if ($mp);
  $options.="-keepmpdir " if ($keepmpdir);
  $options.="-new $outtag $intag ";
  $options.="convpdb.pl -merge - $refpdb ";

  &GenUtil::log("predict","merge structures in $intag with $fragrefpdb");
  &GenUtil::log("predict","  calling ensrun.pl $options");

  system "ensrun.pl $options";
}

## ensruns ######

sub ensruns {
  my $ensdir=shift;
  my $tag=shift;
  my $ens=Ensemble->new($tag,$ensdir);
  my $flist=$ens->fileList();
  return $#{$flist}+1;
}
