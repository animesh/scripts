#!/usr/bin/perl -w
# Calculate and print "average" quality values for each position in a
# Solexa FASTQ file.

use strict;
use Getopt::Long;

my $USAGE = "fastqqc.pl [-c numreads] [-r readlen] [-tsv] fq\n";

my $readlen = 75;
my $cutoff = undef;
my $printqvstats = 0;
my $dotsv = 0;

my $result = GetOptions(
 "c=s"    => \$cutoff,
 "r=s"    => \$readlen,
 "qv"     => \$printqvstats,
 "tsv"    => \$dotsv,
);


my $filename = shift @ARGV or die $USAGE;
open(FQ, $filename) || die "Could not open .fq";

print STDERR "Analyzing $cutoff reads\n" if defined $cutoff;

## Initialize
#####################################################################

my $reads = 0;
my $bpsum = 0;

my @mins;
my @maxs;
my @tots;

my @nsPerRead;
my @posCnts;

for (my $i = 0; $i < $readlen; $i++)
{
  $mins[$i] = 255;
  $maxs[$i] = 0;
  $tots[$i] = 0;

  $nsPerRead[$i] = 0;

  $posCnts[$i]->[0] = 0; ## A
  $posCnts[$i]->[1] = 0; ## C
  $posCnts[$i]->[2] = 0; ## G
  $posCnts[$i]->[3] = 0; ## T
  $posCnts[$i]->[4] = 0; ## N
}


## Scan the reads
#####################################################################

my $i = 0;
while(<FQ>) 
{
  $i++;

  if (($i % 4) == 1)
  {
    die "ERROR Line $i: Expected @ but saw \"$_\"" if !/^@/;
  }
  elsif (($i % 4) == 3)
  {
    die "ERROR Line $i Expected + but saw \"$_\"" if !/^\+/;
  }
  elsif(($i % 4) == 2) 
  {
    chomp;

    # Sequence line
    $_ = uc($_);
    $bpsum += length($_);
  
    my $ns = 0;
  
    for(my $i = 0; $i < length($_) && $i < $readlen; $i++) 
    {
      my $c = substr($_, $i, 1);
  
      if    ($c eq 'A') { $posCnts[$i]->[0]++; }
      elsif ($c eq 'C') { $posCnts[$i]->[1]++; }
      elsif ($c eq 'G') { $posCnts[$i]->[2]++; }
      elsif ($c eq 'T') { $posCnts[$i]->[3]++; }
      else              { $posCnts[$i]->[4]++; $ns++; }
    }
  
    $nsPerRead[$ns]++;
  } 
  else 
  {
    # Quality line
    for(my $i = 0; $i < length($_) && $i < $readlen; $i++) 
    {
      my $oi = (ord(substr($_, $i, 1)));
      $tots[$i] += $oi;
  
      if($oi < $mins[$i]) { $mins[$i] = $oi; }
      if($oi > $maxs[$i]) { $maxs[$i] = $oi; }
    }
  
    $reads++;
  }
  
  last if (defined $cutoff) && ($reads >= $cutoff);
}

my $bp = sprintf("%0.2f", $bpsum/$reads);
print "Analyzed $reads $bp bp reads\n" if !$dotsv;


## QV statistics
#####################################################################

if ($printqvstats)
{
  # Print averages
  print "Average:\n";
  my $istr = "";
  my $i33str = "";
  my $i64str = "";
  for(my $i = 0; $i < $readlen; $i++) {
      last if $tots[$i] == 0;
      my $q = $tots[$i] * 1.0 / $reads;
      my $rq = int($q + 0.5);
      print chr($rq);
      $istr .= "$rq ";
      $i33str .= ($rq-33)." ";
      $i64str .= ($rq-64)." ";
  }
  print "\n$istr\n\n$i33str\n\n$i64str\n";
  print "\n";

  # Print mins
  print "Min:\n";
  $istr = "";
  $i33str = "";
  $i64str = "";
  for(my $i = 0; $i < $readlen; $i++) {
      print chr($mins[$i]);
      my $rq = $mins[$i];
      $istr .= "$rq ";
      $i33str .= ($rq-33)." ";
      $i64str .= ($rq-64)." ";
  }
  print "\n$istr\n\n$i33str\n\n$i64str\n";
  print "\n";

  # Print maxs
  print "Max:\n";
  $istr = "";
  $i33str = "";
  $i64str = "";
  for(my $i = 0; $i < $readlen; $i++) {
      print chr($maxs[$i]);
      my $rq = $maxs[$i];
      $istr .= "$rq ";
      $i33str .= ($rq-33)." ";
      $i64str .= ($rq-64)." ";
  }
  print "\n$istr\n$i33str\n$i64str\n";
  print "\n";
}




## Base Composition
#####################################################################

if ($dotsv)
{
  print "pos\t\%A\t\%C\t\%G\t\%T\t\%N\tQ\tN\n";
}
else
{
  print "pos\t\%A  \t\%C  \t\%G  \t\%T  \t\%N  \t Q\n";
}

if ($dotsv)
{
  for(my $i = 0; $i < $readlen; $i++) 
  {
    printf "%d\t", $i;
    
    for (my $k = 0; $k < 5; $k++)
    {
      printf "%.1f\t", 100*$posCnts[$i]->[$k]/$reads;
    }
    
    my $q = $tots[$i] * 1.0 / $reads;
    my $rq = int($q + 0.5) - 64;
    printf "%d\t%d\n", $rq, $nsPerRead[$i];
  }
}
else
{
  for(my $i = 0; $i < $readlen; $i++) 
  {
    printf "%4d\t", $i+1;
    
    for (my $k = 0; $k < 5; $k++)
    {
      printf "%02.1f\t", 100*$posCnts[$i]->[$k]/$reads;
    }
    
    my $q = $tots[$i] * 1.0 / $reads;
    my $rq = int($q + 0.5) - 64;
    printf "%2d\n", $rq;
  }
}


## Ns per read
#####################################################################

if (!$dotsv)
{
  print "Ns per read:\n";
  for (my $k = 0; $k < $readlen; $k++)
  {
    if ($nsPerRead[$k])
    {
      printf "% 4d:%d\n", $k, $nsPerRead[$k];
    }
  }
}
