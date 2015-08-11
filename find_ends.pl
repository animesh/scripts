#!/usr/local/bin/perl

$infile = $ARGV[0];
$ovlpfile = $ARGV[1];

$MARGIN = 100;
$BEG = 50;       # how far from the beginning the true beginning can be

if (defined $ovlpfile){
    open(OVLP, $ovlpfile) || die ("Cannot open \"$ovlpfile\": $!\n");
    while (<OVLP>){
	@recs = split;
	$recs[0] =~ /(\d+)\(\d+\)/;
	$ctg1 = $1;
	$recs[3] =~ /(\d+)\(\d+\)/;
	$ctg2 = $2;
	
	$l1 = ($recs[1] < $recs[2]) ? $recs[1] : $recs[2];
	$r1 = ($recs[1] < $recs[2]) ? $recs[2] : $recs[1];
	$l2 = ($recs[4] < $recs[5]) ? $recs[4] : $recs[5];
	$r2 = ($recs[4] < $recs[5]) ? $recs[5] : $recs[4];
	
	if ($l1 < $BEG) {
	    $ctg1 .= "B";
	} else {
	    $ctg1 .= "E";
	}
	if ($l2 < $BEG) {
	    $cgt2 .= "B";
	} else {
	    $ctg2 .= "E";
	}
	
	if (! exists $left{$ctg1} || $left{$ctg1} > $l1){
	    $left{$ctg1} = $l1;
	}
	if (! exists $left{$ctg2} || $left{$ctg2} > $l2){
	    $left{$ctg2} = $l2;
	}
	if (! exists $right{$ctg1} || $right{$ctg1} < $r1){
	    $right{$ctg1} = $r1;
	}
	if (! exists $right{$ctg2} || $right{$ctg2} < $r2){
	    $right{$ctg2} = $r2;
	}
#	print STDERR "$ctg1 ($left{$ctg1}, $right{$ctg1}) -  $ctg2 ($left{$ctg2}, $right{$ctg2}) \n";
    }
    close(OVLPS);
} # if defined ovlpfile

open(IN, $infile) || die ("Cannot open \"$infile\": $!\n");

while (<IN>){
    if (/^\#\#(\S+) (\d+) (\d+)/){
	$contig = $1;
	$contiglen = $3;

#	print STDERR "$contig (", $left{"${contig}B"}, ", ", 
	$right{"${contig}B"}, ") (", $left{"${contig}E"}, ", ", 
	$right{"${contig}E"}, ")\n";
	print "$contig\n";
	next;
    }
    if (/^\#(\w+)\((\d+)\).*checksum. \{(\d+) (\d+)\}/){
	$seq = $1;
	$off = $2;
	$sl = $3;
	$sr = $4;

	if (defined $ovlpfile && exists $right{"${contig}B"} && 
	    $off < $right{"${contig}B"} ||
	    ! defined $ovlpfile && $off < $MARGIN){
	    if (! exists $seen{$seq}){
		$seen{$seq} = 1;
#		print STDERR "$seq ($off, $sl, $sr) from $contig ($contiglen) excluded due to $off < ",
		$right{"${contig}B"}, " or < $MARGIN\n";
		print "\t$seq B\n";
	    }
	}
	if (defined $ovlpfile && exists $left{"${contig}E"} &&
	    $off + abs($sl - $sr) + 1 > $left{"${contig}E"} || 
	    ! defined $ovlpfile && 
	    $off + abs($sl - $sr) + 1 > $contiglen - $MARGIN){
	    if (! exists $seen{$seq}){
		$seen{$seq} = 1;
#		print STDERR "$seq ($off, $sl, $sr) from $contig ($contiglen) excluded due to ", $off + abs($sl - $sr) + 1, "  > ",
		$left{"${contig}E"},  " or > ", $contiglen - $MARGIN, "\n";
		print "\t$seq E\n";
	    }
	}
    }
}

close(IN);
