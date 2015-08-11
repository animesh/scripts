#!/usr/bin/perl -w -s

##############################
#
# This script compresses/uncompresses a file composed entirely of ACG and
# T (and possibly newlines). If compressing assumes that each line's length is a multiple of
# four.
#
#############################

# Would have to do this if we didn't have -s above
#if ($ARGV[0] eq "-d") {
#  $d=1;
#  shift @ARGV;
#}

if ($d) {
  %decode =index.html (
	     "00" => "A",
	     "01" => "C",
	     "10" => "G",
	     "11" => "T"
	    );
  undef $/;                 #for slurping
  $_ = unpack "B*", <>;     #$_ is a string of 0s and 1s
  while(s/..//){
    print $decode{$&};
  }
}
else {
  %code =index.html (
	   "A" => "00",
	   "C" => "01",
	   "G" => "10",
	   "T" => "11"
	  );
  while (<>) {
    chomp;              #may be a newline to get rid of
    s/./$code{$&}/g;
    print pack "B*", $_;
  }
}
