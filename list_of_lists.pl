#!/usr/bin/perl
#list of lists
use warnings;
use strict;

my (@outer,@inner);
foreach my $element (1..3){
  @inner = ("one","two",$element);
  push @outer, [@inner]; #push reference to copy of inner
}
print ' @outer is ', "@outer\n";

foreach my $outer_el (@outer) {
  foreach (@{$outer_el}) {
    print "$_\n";
  }
  print "\n";
}
