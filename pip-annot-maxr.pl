#!/usr/local/bin/perl
use 5.006_000;
use warnings;
use strict;

my $max = 0;
while (<>) {
    chomp;
    my @F = split;
    if ($#F > 1 && $F[$#F] eq "URL-annot") {
	my $r = $F[$#F-1];
	$max = $r if $r > $max;
    }
}
print "$max\n";

