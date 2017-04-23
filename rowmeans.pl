#!/usr/bin/perl

##############################
#
# This script computes means of rows
# Originally from LLB 99-00
#
#############################


#for the rows

while (<>) {
  chop;
  @row =index.html split;
  while (defined($next = shift @row)) {  #takes off 1st element of @row
    $runningtotal += $next;
    $total++;
  }
  $mean = $runningtotal/$total;
  print "$mean\n";
}