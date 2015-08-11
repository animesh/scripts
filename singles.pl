#!/usr/local/bin/perl

$ctg = $ARGV[0];
$seq = $ARGV[1];

open(CTG, $ctg) || die ("Cannot open \"$ctg\": $!\n");
while (<CTG>){
    if (/^\#([^\#\(\s]+)/){
	$seen{$1} = 1;
    }
}
close(CTG);

print "00000\n";
open(IN, $seq) || die ("Cannot open \"$seq\": $!\n");
while (<IN>){
    if (/^>(\S+)/){
	if (! exists $seen{$1}){
	    print "\t$1\n";
	}
    }
}
close(IN);
