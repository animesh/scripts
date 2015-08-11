#!/usr/bin/perl

##############################
#
# This script flags up a particular pattern in a text file
# Originally from LLB 99-00
#
#############################

while (<>) {
  s/(G|C|T)(GG|AT|TC)/*PATTERN FOUND*$2/g;
  print;
}