#!/usr/local/bin/perl

$MAXSEQ = 2048;
$MINSEQ = 64;
$MINVEC = 60;

use AMOS::AmosLib;

$frgfile = $ARGV[0];
my $splicename = $ARGV[1];

my @splice;
open(SP, $splicename) || die ("Cannot open $splicename: $!\n");
while (<SP>){
    chomp;
    push(@splice, $_);
}
close(SP);
#my @splice = @ARGV[1..$#ARGV];
#$splice = uc($splice);

open(FRG, $frgfile) || die ("Cannot open $frgfile\n");
while ($record = getRecord(\*FRG)){
    my ($rec, $fields, $recs) = parseRecord($record);
    if ($rec eq "FRG"){
         my $seq = $$fields{seq};
	 my @lines = split('\n', $seq);
	 $seq = join('', @lines);
         $seq = uc($seq);

 	 my ($l, $r) = split(',', $$fields{clr});

	 foreach $splice (@splice) {
	     $splice = uc($splice);
	     my $ind = index($seq, $splice);
	     my $lastind = -1;
	     while ($ind > 0 && $ind < $MINVEC){
		 $lastind = $ind;
		 $ind = index($seq, $splice, $ind + 1);
	     }
	     
	     if ($lastind > 0){
		 if ($l < $lastind + length($splice)){
		     print STDERR "trimming sequence $$fields{acc} due to vector ", $lastind + length($splice) - $l + 1, "\n";
		     $l = $lastind + length($splice) + 1;
		 }
	     }
	 } # for each splice

	 if ($r - $l < $MINSEQ) {
	     print STDERR "skipping short sequence $$fields{acc}\n";
	     next;
	 }

	 #print "updating clear range of $nm to $clear{$nm}\n";
	 $record =~ s/clr:(\d+),(\d+)/clr:$l,$r/m;
         $seen{$$fields{acc}} = 1;
	 print $record;
	
	 next;
    } # if rec eq FRG
    if ($rec eq "LKG"){
	if (exists $seen{$$fields{fg1}} && exists $seen{$$fields{fg2}}){
	    print $record;
	}
	next;
    }
    print $record;
}

