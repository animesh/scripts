#!/usr/bin/env perl
#
# evaluate a set of structures
#
# http://mmtsb.scripps.edu/doc/evaluate.pl.html
# 2001, Michael Feig, Brooks group, TSRI
#

sub usage {
  printf STDERR "usage:   evaluate.pl [options] [file(s)]\n";
  printf STDERR "options: [-f file]\n";
  printf STDERR "         [-dir datadir]\n";
  printf STDERR "         [-tag name]\n";
  printf STDERR "         [-cpus num] [-hosts hostfile]\n";
  printf STDERR "         [-mp] [-keepmpdir]\n";
  printf STDERR "         [-prop name[+name]]\n";
  printf STDERR "         [-minpar CHARMMparams]\n";
  printf STDERR "         [-l refPDB min:max[=min:max ...]]\n";
  printf STDERR "         [-cutout]\n";
  printf STDERR "         [-cluster]\n";
  printf STDERR "         [-par limforce=value,limsel=ca|cab|heavy,\n";
  printf STDERR "               hardcutoff=val,hardcutforce=val,\n";
  printf STDERR "               softcutoff=val,softcutforce=val,\n";
  printf STDERR "               clustermaxnum=val,clusterminsize=val,\n";
  printf STDERR "               clustermode=contact|rmsd,\n";
  printf STDERR "               clustercontmaxdist=val,clusterevallevel=val,\n";
  printf STDERR "               clusterevalcrit=avg|avglow|avgcent|best<num>|median,\n";
  printf STDERR "               clusterevallimstd=multiple]\n";
  printf STDERR "         [-opt file]\n";
  printf STDERR "         [-verbose]\n";
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
use Ensemble;
use Molecule;
use Cluster;

my %defminpar = (); 

my %defopt = ( 
  finalrest          => 1,
  conslim            => 1,
  limforce           => 1.0,
  limsel             => "cab",
  hardcutoff         => 16.0,
  hardcutforce       => 10.0,
  softcutoff         => 12.0,
  softcutforce       => 0.5,
  clustermaxnum      => 5,
  clusterminsize     => 20,
  clustermode        => "rmsd",
  clustercontmaxdist => 8.0,
  clusterevallevel   => -1,
  clusterevalcrit    => "avglow",
  clusterevallimstd  => 1.5 
);

my $tag="eval";
my $dir="data";

my $listfile;

my $cpus=1;
my $hostfile;

my $mp=0;
my $keepmpdir=0;

my %minpar=();
my ($fraglist,$fragref);
my $cutout;
my $cluster;
my %par=();

my $filelist=();

my $optfile;

my $minopt="";

my $verbose=0;

my $prop="etot";

while ($#ARGV>=0) {
  if ($ARGV[0] eq "-help" || $ARGV[0] eq "-h") {
    &usage();
  } elsif ($ARGV[0] eq "-f") {
    shift @ARGV;
    $listfile=shift @ARGV;
  } elsif ($ARGV[0] eq "-dir") {
    shift @ARGV;
    $dir=shift @ARGV;
  } elsif ($ARGV[0] eq "-tag") {
    shift @ARGV;
    $tag=shift @ARGV;
  } elsif ($ARGV[0] eq "-cpus") {
    shift @ARGV;
    $cpus=shift @ARGV;
    $minopt.="-cpus $cpus ";
  } elsif ($ARGV[0] eq "-prop") {
    shift @ARGV;
    $prop=shift @ARGV;
  } elsif ($ARGV[0] eq "-hosts") {
    shift @ARGV;
    $hostfile=shift @ARGV;
    $minopt.="-hosts $hostfile ";
  } elsif ($ARGV[0] eq "-mp") {
    shift @ARGV;
    $mp=1;
    $minopt.="-mp ";
  } elsif ($ARGV[0] eq "-keepmpdir") {
    shift @ARGV;
    $keepmpdir=1;
    $minopt.="-keepmpdir ";
  } elsif ($ARGV[0] eq "-minpar") {
    shift @ARGV;
    &GenUtil::parsePar(\%minpar,shift @ARGV);
  } elsif ($ARGV[0] eq "-l") {
    shift @ARGV;
    $fragref=shift @ARGV;
    $fraglist=shift @ARGV;
  } elsif ($ARGV[0] eq "-cutout") {
    shift @ARGV;
    $cutout=1;
    $par{conslim}=0;
  } elsif ($ARGV[0] eq "-cluster") {
    shift @ARGV;
    $cluster=1;
  } elsif ($ARGV[0] eq "-par") {
    shift @ARGV;
    &GenUtil::parsePar(\%par,shift @ARGV);
  } elsif ($ARGV[0] eq "-opt") {
    shift @ARGV;
    $optfile=shift @ARGV;
  } elsif ($ARGV[0] eq "-verbose") {
    shift @ARGV;
    $verbose=1;
  } elsif ($ARGV[0] =~/^-/) {
    printf STDERR "invalid option %s\n",shift @ARGV;
    &usage();
  } else {
    push (@{$filelist},shift @ARGV);
  }    
}

if (defined $listfile && -r $listfile ) {
  my $f=&GenUtil::getInputFile($listfile);
  while (<$f>) {
    chomp;
    push(@{$filelist},$_);
  }
  undef $f;
}

&usage() 
  if ($#{$filelist}<0);

my $ens=Ensemble->new($tag,$dir);

if (defined $optfile) {
  foreach my $o ( split(/:/,$optfile) ) {
    $ens->readOptions($o);
  }
}

$ens->set(fragref=>$fragref, fraglist=>$fraglist);
$ens->setOption(%par);
$ens->setPar(%minpar);

foreach my $p ( keys %defminpar ) {
  if (!defined $ens->getPar() || !defined $ens->getPar()->{$p}) {
    $ens->setPar($p=>$defminpar{$p});
  }
}

foreach my $p ( keys %defopt ) {
  if (!defined $ens->{opt} || !defined $ens->{opt}->{$p}) {
    $ens->setOption($p=>$defopt{$p});
  }
}

$ens->save();

# check in files

printf "checking in %d files\n",$#{$filelist}+1
  if ($verbose);

$ens->readFileList();

my $at=$ens->{par}->{runs}+1;
foreach my $f ( @{$filelist} ) {
  $ens->setFileList($at,$f);
  my $mol=Molecule::new($f);
  $ens->checkinPDB($at++,$mol,0.0);
}

$ens->save();

# cut out vicinity of loop residues

if ($cutout && defined $ens->getFragList()) {
  printf "cutting out protein structure around fragment %s\n",$ens->{par}->{fraglist}
    if ($verbose);

  system "enscut.pl -dir $dir -opt $dir/$tag.options $tag $tag.cut";
  $tag="$tag.cut";
}

$minopt.="-opt $dir/$tag.options ";

# run minimization

printf "running minimization on %d CPU(s)\n",$cpus
  if ($verbose);

system "ensmin.pl -dir $dir $minopt $tag $tag.min";
$tag="$tag.min";

# cluster

my $resens=Ensemble->new($tag,$dir);

if ($cluster) {
  printf "clustering structures\n"
    if ($verbose);
  system "enscluster.pl -dir $dir -opt $dir/$ens->{tag}.options $tag";
  
  open INP,"bestcluster.pl -dir $dir -level $ens->{opt}->{clusterevallevel} -prop $prop -crit $ens->{opt}->{clusterevalcrit} -limstd $ens->{opt}->{clusterevallimstd} $tag |";
  while (<INP>) {
    print "   ### cluster $_";
    chomp;
    s/^ +//;
    my @f=split(/ +/,$_);
    _showResult($ens->{filelist},$prop,$resens,$f[0]);
  }
  close INP;
} else {
  _showResult($ens->{filelist},$prop,$resens);
}

exit 0;

sub _showResult {
  my $filelist=shift;
  my $prop=shift;
  my $ens=shift;
  my $cluster=shift;

  my $plist=$ens->getPropList($prop);

  my $xlist=();

  if (defined $cluster) {
    my $cl=Cluster::new();

    die "no clusters available"
      if (!-r "$ens->{dir}/$ens->{tag}.cluster");
    $cl->readFile("$ens->{dir}/$ens->{tag}.cluster");  

    my $list=$cl->fileList($cluster);
    die "no cluster elements found"
      if (!defined $list);

    foreach my $p ( sort { $a->{inx}<=>$b->{inx} } @{$list} ) {
      push(@{$xlist},$plist->[$p->{inx}-1]);
    }
  } else {
    $xlist=$plist;
  }
  
  foreach my $s ( sort { $a->{val} <=> $b->{val} } @{$xlist}) {
    printf "%d %s %f\n",$s->{inx},$filelist->[$s->{inx}],$s->{val};
  }
}
  


