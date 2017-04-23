#!/usr/local/bin/perl

use AMOS::AmosLib;

$seqfile = $ARGV[0];
$frgfile = $ARGV[1];

open(SEQ, $seqfile) || die ("Cannot open $seqfile\n");
while (<SEQ>){
    if (/^>(\S+) \d+ \d+ \d+ (\d+) (\d+)/){
	$seq = $1;
	$cll = $2;
	$clr = $3;

	$cll -= 1;

	$clear{$seq} = "$cll,$clr";
    }
}
close(SEQ);

open(FRG, $frgfile) || die ("Cannot open $frgfile\n");

while ($record = getRecord(\*FRG)){
    my ($rec, $fields, $recs) = parseRecord($record);
    if ($rec eq "FRG"){
	 my $nm = $$fields{src};
	 my @lines = split('\n', $nm);
	 $nm = join('', @lines);
	 if (exists $clear{$nm}){
	     #print "updating clear range of $nm to $clear{$nm}\n";
	     $record =~ s/clr:(\d+),(\d+)/clr:$clear{$nm}/m;
	     $seen{$$fields{acc}} = 1;
	     print $record;
	 }
	 next;
    }
    if ($rec eq "LKG"){
	if (exists $seen{$$fields{fg1}} && exists $seen{$$fields{fg2}}){
	    print $record;
	}
	next;
    }
    print $record;
}

