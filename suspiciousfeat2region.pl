#!/usr/bin/perl
use lib "/fs/szdevel/amp/AMOS/Linux-x86_64/lib";

use strict;

my $BUFFER = 2000;
my $MIN_TYPES = 2;

my $contigid = -1;
my $rstart;
my $rend;
my $laststart;
my @reasons;
my %reasonshash;


sub printEnd
{
  my $nfea = scalar @reasons;
  my $ntyp = scalar(keys %reasonshash);

  if ( $ntyp >= $MIN_TYPES )
  {
    print "$contigid A $rstart $rend MISASSEMBLY feats:$nfea types:$ntyp\t";
    print join "\t|\t", @reasons;
    print "\n";
#      print
#          "{FEA\n",
#          "clr:$rstart,$rend\n",
#          "typ:A\n",
#          "src:$contigid,CTG\n",
#          "com:\n",
#          "MISASSEMBLY feats:$nfea types:$ntyp\n";
#      foreach my $reason (@reasons) { print "$reason\n"; }
#      print ".\n}\n";
  }

  @reasons = ();
  %reasonshash = ();
}


while (<>)
{
  my @vals = split /\s+/, $_;

  my $cid    = shift @vals;
  my $type   = shift @vals;
  my $cstart = shift @vals;
  my $cend   = shift @vals;
  my $desc   = shift @vals;

  if ($cid != $contigid)
  {
    printEnd();

    ## new contig
    $contigid  = $cid;
    $laststart = -10000000;
    $rstart    = -10000000;
    $rend      = -10000000;
  }

  if ($cstart < $laststart)
  {
    die "Features are unsorted!";
  }

  if ( $cstart > $rend + $BUFFER )
  {
    printEnd();

    ## new region 
    $rstart = $cstart;
    $rend = $cend;
  }
  elsif ( $cend > $rend )
  {
    $rend = $cend;
  }

  $laststart = $cstart;

  push @reasons, "$cstart\t$cend\t$type\t$desc @vals";
  $reasonshash{$desc}++;
}

printEnd();
