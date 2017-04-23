#!/usr/bin/perl

##############################
#
# This script 
# (1) extracts a HMM from a messy text file
# (2) computes forward probabilities (this needs improving)
# Originally from LLB 99-00
#
#############################

#basic idea if we ever see P( something) spaces|=index.html number
#then it is a probability

while ( <> ) {                  #just put hmm.txt on the command line
  while ( /P\(([^\)]+)\) *=index.html *(([0-9]|\.)+)/ ) {
    $stuff=$1;        #a bit more readable!
    $prob=$2;         #also prevents accidental overwrites..
    $rest=$';         #..in subsequent pattern matching
    if ( $stuff =~ /\|/ ) {    #if it has a "|" then it's a conditional py
      if ( $stuff =~ /q_\{t/ ) {  #must be state transition py
        $stuff =~ s/q_\{t\+1}=//;     #get rid of this stuff
        $stuff =~ s/q_\{t}=//;        #and this
        ($new,$old) = split /\|/, $stuff;
        $a{$old}{$new}=$prob;
      }
      else {                      #emission probability
        ($sym,$state) = split /\|/, $stuff;
        $b{$state}{$sym}=$prob;
      }
    }
    else {
      $pi{$stuff}=$prob;        #initial probability
    }
    $_=$rest;       #everything after the match
  }
}

#OK this one you just have to type into your code
#easier to just do $b{"S1"}{"A"}=0.25 etc

$b{"S2"} = {
          "A" => 0.25,
          "C" => 0.25,
          "G" => 0.25,
          "T" => 0.25
         };

print "Initial probabilities:\n";
foreach $state (sort keys %pi) {
  print "P($state)=$pi{$state}\n";
}

print "\n\nEmission probabilities:\n";
foreach $state (sort keys %b) {
  foreach $sym (sort keys %{$b{$state}}) {
    print "P($sym|$state)=$b{$state}{$sym}\n";
  }
}

print "\n\nTransition probabilities:\n";
foreach $oldstate (sort keys %a) {
  foreach $newstate (sort keys %{$a{$oldstate}}) {
    print "P($newstate|$oldstate)=$a{$oldstate}{$newstate}\n";
  }
}


$t1 = &fprob("ACGT");
$t2 = &fprob("AC");
$t3 = &fprob("C");
$t4 = &fprob("A");
$t5 = &fprob("G");
$t6 = &fprob("T");

print "$t1, $t2, $t3, $t4, $t5, $t6\n";


sub fprob {
  @string = split //, $_[0];   #make into an array called $string!
  $first = shift @string;      #grab first to initialise
  foreach $j (keys %pi) {
    $alpha{$j} = ($pi{$j}) * ($b{$j}{$first});
  }                            #initialisation complete
  while (defined($next = shift @string)) { #just update
    foreach $j (keys %pi) {
      $tmp = 0;
      foreach $i (keys %pi) {
        $tmp += ($alpha{$i}*$a{$i}{$j});
      }
      $newalpha{$j} = $tmp*$b{$j}{$next};
    }
    %alpha = %newalpha;   #only now clobber alpha with newalpha
  }
  $tmp=0;
  foreach $p (%alpha){    #final adding up
    $tmp += $p;
  }
  return $tmp;
}
  
