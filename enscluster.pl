#!/usr/bin/env perl
#
# clusters a set of ensemble structures 
#
# http://mmtsb.scripps.edu/doc/enscluster.pl.html
# 2001, Michael Feig, Brooks group, TSRI
#

sub usage {
  printf STDERR "usage:   enscluster.pl [options] tag\n";
  printf STDERR "options: [-jclust] [-kclust]\n";
  printf STDERR "         [-maxnum value] [-minsize value] [-maxlevel value]\n";
  printf STDERR "         [-radius value] [-[no]iterate]\n";
  printf STDERR "         [-mode rmsd|contact|phi|psi|phipsi|mix]\n";
  printf STDERR "         [-contmaxdist value] [-mixfactor value]\n";
  printf STDERR "         [-l min:max[=min:max ...]]\n";
  printf STDERR "         [-dir workdir]\n";
  printf STDERR "         [-opt file[:file]]\n";
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

use Cluster;
use Ensemble;
use GenUtil;

my %defpar = (
 clustermaxnum      => 4,
 clustermaxlevel    => 999,
 clustermode        => "rmsd",
 clustercontmaxdist => 10.0,
 clustermethod      => "kclust",
 clusterradius      => 2.5,
 clusteriterate     => 1,
 clustermixfactor   => 0.3
	     );

my %par;

my $fraglist;

my $contmaxdist;

my $workdir=".";
my $tag;

my $optfile;

my $centroids=0;

my $from;
my $to;

while ($#ARGV>=0) {
  if ($ARGV[0] eq "-maxnum") {
    shift @ARGV;
    $par{clustermaxnum}=shift @ARGV;
  } elsif ($ARGV[0] eq "-jclust") {
    shift @ARGV;
    $par{clustermethod}="jclust";
  } elsif ($ARGV[0] eq "-kclust") {
    shift @ARGV;
    $par{clustermethod}="kclust";
  } elsif ($ARGV[0] eq "-minsize") {
    shift @ARGV;
    $par{clusterminsize}=shift @ARGV;
  } elsif ($ARGV[0] eq "-maxlevel") {
    shift @ARGV;
    $par{clustermaxlevel}=shift @ARGV;
  } elsif ($ARGV[0] eq "-mode") {
    shift @ARGV;
    $par{clustermode}=shift @ARGV;
  } elsif ($ARGV[0] eq "-radius") {
    shift @ARGV;
    $par{clusterradius}=shift @ARGV;
  } elsif ($ARGV[0] eq "-iterate") {
    shift @ARGV;
    $par{clusteriterate}=1;
  } elsif ($ARGV[0] eq "-noiterate") {
    shift @ARGV;
    $par{clusternoiterate}=1;
  } elsif ($ARGV[0] eq "-mixfactor") {
    shift @ARGV;
    $par{clustermixfactor}=shift @ARGV;
  } elsif ($ARGV[0] eq "-contmaxdist") {
    shift @ARGV;
    $par{clustercontmaxdist}=shift @ARGV;
  } elsif ($ARGV[0] eq "-run") {
    shift @ARGV;
    ($from,$to)=split(/:/,shift @ARGV);
  } elsif ($ARGV[0] eq "-l") {
    shift @ARGV;
    $fraglist=shift @ARGV;
  } elsif ($ARGV[0] eq "-opt") {
    shift @ARGV;
    $optfile=shift @ARGV;
  } elsif ($ARGV[0] eq "-centroids") {
    shift @ARGV;
    $centroids=1;
  } elsif ($ARGV[0] eq "-dir") {
    shift @ARGV;
    $workdir=shift @ARGV;
  } elsif ($ARGV[0] eq "-help" || $ARGV[0] eq "-h") {
    &usage();
  } elsif ($ARGV[0] =~ /^-/) {
    die "unknown option $ARGV[0]";
  } else {
    $tag=shift @ARGV
      if (!defined $tag);
  }
}

&usage() if (!defined $tag);

my $ens=Ensemble->new($tag,$workdir);

if (defined $optfile) {
  foreach my $o ( split(/:/,$optfile) ) {
    $ens->readOptions($o);
  }
}

$ens->set(fraglist=>$fraglist);

$ens->setOption(%par);

foreach my $p ( keys %defpar ) {
  if (!defined $ens->{opt} || !defined $ens->{opt}->{$p}) {
    $ens->setOption($p=>$defpar{$p});
  }
}

die "contact clustering not available with kclust"
  if ($ens->{opt}->{clustermethod} eq "kclust" && 
      $ens->{opt}->{clustermode} eq "contact");

die "$ens->{opt}->{clustermode} clustering not available with jclust"
  if ($ens->{opt}->{clustermethod} eq "jclust" && 
      $ens->{opt}->{clustermode} eq "mix" ); 

$ens->save();

my $filelist=$ens->fileList();
$ens->{opt}->{clusterminsize}=$#{$filelist}+1 if (!defined $ens->{opt}->{clusterminsize});

my $cluster=Cluster::new(filetype=>"pdb", 
			 clustermode=>$ens->{opt}->{clustermode},
			 contmaxdist=>$ens->{opt}->{clustercontmaxdist},
			 fraglist=>$ens->{par}->{fraglist},
                         fitfragflist=>undef,
                         maxnum=>$ens->{opt}->{clustermaxnum},
			 minsize=>$ens->{opt}->{clusterminsize},
			 radius=>$ens->{opt}->{clusterradius},
                         iterate=>$ens->{opt}->{clusteriterate},
			 mixfactor=>$ens->{opt}->{clustermixfactor},
			 method=>$ens->{opt}->{clustermethod});

$cluster->setFileList($filelist);
$cluster->clusterHierarchy($ens->{opt}->{clustermaxlevel});

$cluster->writeFile($ens->{dir}."/".$ens->{tag}.".cluster");

if ($centroids) {
  if (-r "$ens->{dir}/centroids") {
    system "/bin/rm -f $ens->{dir}/centroids/$ens->{tag}-* >&/dev/null";
  } else {
    system "mkdir $ens->{dir}/centroids";
  }
  $cluster->writeCentroids($ens->{dir}."/centroids/$ens->{tag}");
}


exit 0;

