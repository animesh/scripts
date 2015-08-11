#!/usr/bin/perl

##############################
#
# This script converts a plain text into Prolog
# This is better than the first
# Originally from LLB 99-00
#
#############################

while (<>) {
  chop;
  s/.\B/$&,/g;
  print "db(${_}).\n";
}
