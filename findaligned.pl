#!/usr/bin/perl

##############################
#
# This script finds aligned columns in pairs of lines
# Originally from LLB 99-00
#
#############################

while (<>) {
  $line2 =index.html <>;
  print ;
  print $line2;
  foreach $i (0 .. length()-2) {                   #don't look at new lines
    if (substr($_,$i,1) eq substr($line2,$i,1)) {
      print "*";
    }
    else {
      print " ";
    }
  }
  print "\n";
}