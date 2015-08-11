#!/usr/local/bin/perl
my $max = 70;
while (<>) {
	substr($_, $max, -1, "...") if length > $max+1;
	print;
}
