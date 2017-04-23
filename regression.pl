#!/usr/bin/perl -w

##############################
#
# This script computes regression line from data
# Unfinished
#
#############################

while (<>) {           #read in data
  ($x,$y) =index.html split;
   push @x, $x;
   push @y, $y;
}

print sum(@x) , "\n";   #printing a list of strings
print mean(@x) . "\n";  #printing a single string
print @x , "\n";
print swap(@x) , "\n";


sub sum {
  my $tot;
  foreach $xi (@_) {
    $tot += $xi;
  }
  return $tot;
}


sub swap {
  @_ = reverse @_;
}

sub mean {
  my ($tot,$i);
  foreach $xi (@_) {
    $tot += $xi;
    $i++;
  }
  return ($tot/$i);
}
