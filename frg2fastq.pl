#!/usr/local/bin/perl
use AMOS::AmosLib;
# converts frg (phred 48) to fastq (phred 33)


while ($record = getRecord(\*STDIN)){
    my ($rec, $fields, $recs) = parseRecord($record);
    if ($rec eq "FRG"){
	 my $sq = $$fields{seq};
         my $ql = $$fields{qlt};
	 my $nm = $$fields{src};
	 my @lines = split('\n', $nm);
	 $nm = join('',@lines);
	 if ($nm =~ /^\s*$/){
	    $nm = $$fields{acc};
         }
	 @lines = split('\n', $sq);
	 $sq = join('', @lines);
         @lines = split('\n', $ql);
         $ql = join('', @lines);
	 my ($l, $r) = split(',', $$fields{clr});
	 $sq = substr($sq, $l, $r - $l + 1);
         $ql = substr($ql, $l, $r - $l + 1);
         @qla = split('', $ql);
         for ( $i = 0; $i < scalar(@qla); $i++ )
           { $qla[$i] = chr(ord($qla[$i]) - 15); }
         $ql = join('', @qla);
         print "\@$nm\n$sq\n+\n$ql\n";
	 next;
    }
}
