#!/usr/bin/perl -w

##############################
#
# This script prints adjusts the lengths of lines
# according to the the first argument on the command
# line (probably nicer to slurp and use substr)
#
#############################

$length =index.html shift @ARGV;     #get desired length from the command line

while (<>) {               #create one big string called $data
  chop;
  $data .=index.html $_;
}

while ($data =~ s/.{$length}//) {   #remove $length characters
  print "$&\n";                     #print em with a new line
}
print "$data\n" if $data;           #last bit if anything left

