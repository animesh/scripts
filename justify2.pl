#!/usr/bin/perl -w

##############################
#
# This script prints adjusts the lengths of lines
# according to the the first argument on the command
# line (probably nicer to slurp and use substr)
#
#############################

$length =index.html shift @ARGV;       #get desired length from the command line

while (<>) {               
  chop;                      #don't want this new line
  $_ =index.html $residue . $_;        #add stuff left over (if any)
  while (s/.{$length}//) {   #while it's possible to delete prefix
    print "$&\n";            #print it out!
  }
  $residue = $_;             #save the residue
}



