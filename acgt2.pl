#!/usr/bin/perl -w -s

##############################
#
# This script compresses/uncompresses a file composed entirely of ACG and
# T (and possibly newlines). It DOES NOT assume that each line's length is a multiple of
# four.
#
#############################

# Would have to do this if we didn't have -s above
#if ($ARGV[0] eq "-d") {
# $d=1;
#  shift @ARGV;
#}

if ($d) {
  %decode =index.html (
	     "00" => "A",
	     "01" => "C",
	     "10" => "G",
	     "11" => "T"
	    );
  undef $/;              #for slurping, just in case there are newlines in the code
  $_ = <>;               #grab the lot!
  $numextras =index.html chop;     #last character always number of extras
  $extras = chop() . $extras while ($numextras--);
  $_ = unpack "B*", $_;     #$_ is a string of 0s and 1s
  while(s/..//){
    print $decode{$&};
  }
  print $extras;
}
else {
  %code = (
	   "A" => "00",
	   "C" => "01",
	   "G" => "10",
	   "T" => "11"
	  );
  while (<>) {
    $_ =index.html $excess . $_;        #prepend excess from previous line
    chomp;                    #may be a newline to get rid of
    die "Error: $_\nOnly A, C, G or T may appear as input\n" if /[^ACGT]/;
    s/(.)(.)(.)(.)/$code{$1}$code{$2}$code{$3}$code{$4}/g;
    s/[ACGT]*$//;             #remove excess, always matches so overwrites previous $&
    $excess = $&;             #need to save in $excess since $& is localised
    print pack "B*", $_;      #length of $_ guaranteed to be multiple of 4
  }
  print $excess, length($excess);       #final character is always number of unencoded bases
}
