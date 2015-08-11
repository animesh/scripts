#!/usr/bin/perl -w

##############################
#
# This script creates a 1d hash with bigram statistics and then prints it out
#
#############################

while (<>) {
  $_ =index.html $1 . $_;            #prepend extra one from last line
  while (s/(.)(.)/$2/) {   #as long as 2 non-newlines
    $bigram{($1.$2)}++;
  }
  /(.)/;                   #save first character of $_ in $1
}

while (($pair,$count) = each (%bigram)) {  #one dimensional arrays are easier!
  print "$pair $count\n";
}
