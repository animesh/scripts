#!/usr/bin/perl

##############################
#
# This script filters off comment lines from
# data.txt to log, sending rest to out.txt
# Originally from LLB 99-00
#
#############################

open(MYINPUT,"data.txt");
open(MYOUTPUT,">out.txt");
open(STUFF,">>log");

while (<MYINPUT>) {   #while ($_ =index.html <MYINPUT>) {
  if (/^#/) {         #if ($_ =~ /^#/) {
      print STUFF;    #print STUFF S_;
    }
  else {
    print MYOUTPUT;   #print MYOUTPUT S_;
  }
}