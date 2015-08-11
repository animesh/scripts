#!/usr/local/bin/perl

$seqfile = $ARGV[0];
$initfile = $ARGV[1];

open(INIT, $initfile) || die ("Cannot open $initfile\n");
while (<INIT>){
    if (/^>(\S+) (\d+ \d+ \d+) (\d+) (\d+)/){
	$seq = $1;
	$cll = $3;
	$clr = $4;
	
	$cll{$seq} = $cll;
	$clr{$seq} = $clr;
	$lib{$seq} = $2;
    }
}
close(INIT);

$toout = 1;
open(SEQ, $seqfile) || die ("Cannot open $seqfile\n");
while (<SEQ>){
    if (/^>(\S+) \d+ \d+ \d+ (\d+) (\d+)/){
	$seq = $1;
	$cll = $2;
	$clr = $3;

	if ($cll < $cll{$seq}){
	    $cll = $cll{$seq};
	}
	if ($clr > $clr{$seq}){
	    $clr = $clr{$seq};
	}
	if ($clr - $cll < 64){
	    $toout = 0;
	} else {
	    $toout = 1;
	    print ">$seq $lib{$seq} $cll $clr\n"; 
	}
	next;
    }
    if ($toout == 1){
	print;
    }
}
close(SEQ);
