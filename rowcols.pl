#!/usr/bin/perl

##############################
#
# This script computes means of columns
# Originally from LLB 99-00
#
#############################

while (<>) {
  chop;
  @row =index.html split;
  foreach $i (0 .. $#row) {         # .. is the range operator
    $runningtotal[$i] += $row[$i];
  }
  $total++;
}

foreach $t (@runningtotal) { #$t grabs each defined value in @runningtotal
  $mean = $t/$total;
  print "$mean\n";
}