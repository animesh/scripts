#!/usr/local/bin/perl

$infile = $ARGV[0];
$exclfile = $ARGV[1];

if (exists $ARGV[2] && $ARGV[2] eq "include"){
    $revert = 0;
} else {
    $revert = 1;
}

open(EXCL, $exclfile) || die ("Cannot open \"$exclfile\": $!\n");
while (<EXCL>){
    chomp;
    if (/^(\S+)/){
	$contig = $1;
	$exclude{$1} = 1;
    }
    if (/^\t(\S+)/){
#	print STDERR "excluding \"$1\"\n";
	$exclude{$1} = 1;
	$contigs{$contig}++;
    }
}
close(EXCL);

$toprint = $revert;
open(IN, $infile) || die ("Cannot open \"$infile\": $!\n");
while (<IN>){
    if (/^\#\#(\S+) (\d+) (\d+)/){
	$ctg = $1; $nseq = $2; $len = $3;
	$nseq -= $contigs{$ctg};

	print "\#\#$ctg $nseq $len bases, 00000000 checksum.\n";

	$toprint = $revert;
	next;
    }
    if (/^[\#>]([^\#][^\s\(]+)/){ # header found
#	print STDERR "Checking \"$1\"\n";
	if (exists $exclude{$1}){
#	    print STDERR "bye bye\n";
	    $toprint = 1 - $revert;
	} else {
	    $toprint = $revert;
	}
    }
    if ($toprint == 1){
	print;
    }
}
close(IN);
