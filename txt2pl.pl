#!/usr/bin/perl

##############################
#
# This script converts a plain text into Prolog
# Should use join!!
# Originally from LLB 99-00
#
#############################

while (<>) {
  chop;                 #get rid of new line character
  @line =index.html split //;     #split $_ into array, one element per character
  $first = shift @line; #get first element (and delete it from @line)
  print "db($first";    #$first is printed out specially
  while(defined($next = shift @line))  #as long as we have something to print
    {
      print ",$next";                  # print it
    }
  print ").\n"          #finish off
}