#!/usr/bin/perl -w
use strict;

## Scan the snp report and cluster the snps. A cluster is based on the SNPs
## within a window- there must be $WINDOWSNPS snps within $WINDOWSIZE bp
## for the window to be active. The resulting feature is the maximal range
## where there is a window of sufficient badness

## Minimum number of correlated conflicting reads to be considered a true SNP
my $MINCORRELATED = 2;

## Number of SNPs in a window to declare a feature
my $WINDOWSNPS = 2;

## Size of the window to seed a feature
my $WINDOWSIZE = 500;

## Size of fringe of window to consider
my $WINDOWFRINGE = 1000;


my @windowsnps;
my @featuresnps;
my $contigid = undef;

my $lastsnppos;
my $firstsnppos;
my $snpcount = 0;

sub printResults
{
  if ($snpcount)
  {
    my $span = $lastsnppos - $firstsnppos + 1;
    my $dist = ($snpcount > 1) ? sprintf("%.02f", $span / ($snpcount-1)) : "1.00";

    print "$contigid P $firstsnppos $lastsnppos HIGH_SNP $snpcount $dist\n";
  }
}

while (<>)
{
  next if /^AmblID/;

  chomp;
  my @vals = split /\s+/, $_;

  if (!defined $contigid || $contigid ne $vals[0])
  {
    printResults();

    @windowsnps = ();
    @featuresnps = ();
    $lastsnppos = undef;
    $snpcount = 0;

    $contigid = $vals[0];
  }

  my $curpos = $vals[1];
  my $cursnps = $vals[5];

  next if $cursnps < $MINCORRELATED;

  ## Check if last feature is now definitely dead
  if ($snpcount && ($curpos - $lastsnppos > $WINDOWFRINGE))
  {
    printResults();

    @windowsnps = ();
    @featuresnps = ();
    $lastsnppos = undef;
    $snpcount = 0;
  }

  ## find snps that are within WINDOWSIZE of current position
  @windowsnps = grep {($curpos - $_) < $WINDOWSIZE} @windowsnps;
  push @windowsnps, $curpos;
  push @featuresnps, $curpos;

  my $windowcount = scalar @windowsnps;

  if ($snpcount == 0)
  {
    ## If this cluster has sufficient number of snps
    ## This window seeds the cluster
    if ($windowcount >= $WINDOWSNPS)
    {
      my $first = $windowsnps[0];

      ## Get the leftmost position that is within the fringe
      for (my $i = scalar @featuresnps - 1; $i >= 0; $i--)
      {
        if ($first - $featuresnps[$i] <= $WINDOWFRINGE)
        {
          $firstsnppos = $featuresnps[$i];
          $snpcount++;
        }
      }
    }
  }
  else
  {
    $snpcount++;
  }

  $lastsnppos = $curpos;
}

printResults();

exit 0;
