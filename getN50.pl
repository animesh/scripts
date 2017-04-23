#!/usr/local/bin/perl

use TIGR::Foundation;
use AMOS::ParseFasta;

if ( scalar(@ARGV) != 1 ) {
    if ( scalar(@ARGV) != 2 ) {
	die "USAGE: $0 <fasta> [genome size]\n";
    } else {
	$genomesize = $ARGV[1];
    }
} else {
    $genomesize = 0;
}

$tf = new TIGR::Foundation;

if (!defined $tf){
    die ("Bad foundation\n");
}

open(IN, $ARGV[0]) || $tf->bail("Cannot open $ARGV[0]: $!\n");
$fr = new AMOS::ParseFasta(\*IN);

if (!defined $fr){
    die ("Bad reader\n");
}

@lens = ();
while (($head, $body) = $fr->getRecord()){
    push @lens, length($body);
}

@lens = sort { $b <=> $a } @lens;

if ( $genomesize <= 0 ) {
    $genomesize = 0;
    foreach $len (@lens) {
	$genomesize += $len;
    }
}

$sum = 0;
$n50 = 0;
foreach $len (@lens) {
    $sum += $len;

    if ( $sum > $genomesize / 2  &&  $n50 == 0 ) {
	$n50 = $len;
    }
}

print "NUM ";
print scalar(@lens);
print "\nAVG ";
print $sum / scalar(@lens);
print "\nN50 ";
print $n50;
print "\n";
