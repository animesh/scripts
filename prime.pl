#!/usr/bin/perl
#Test primality upto 16 digit number
use strict;
my $test_no=shift @ARGV;
print "$test_no\n";
for(my $i=2;$i<=int(sqrt($test_no));$i++){
	if (((int($test_no))%($i))==0) {
		die "$test_no is not Prime, divisible by $i"; 
	}
}
print "$test_no is Prime"; 
