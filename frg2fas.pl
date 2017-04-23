while ($record = getRecord(\*STDIN)){
    my ($rec, $fields, $recs) = parseRecord($record);
    if ($rec eq "FRG"){
	 my $sq = $$fields{seq};
	 my $nm = $$fields{src};
	 my @lines = split('\n', $nm);
	 $nm = join('',@lines);
	 if ($nm =~ /^\s*$/){
	    $nm = $$fields{acc};
         }
	 @lines = split('\n', $sq);
	 $sq = join('', @lines);
	 my ($l, $r) = split(',', $$fields{clr});
	 $sq = substr($sq, $l, $r - $l + 1);
	 printFastaSequence(\*STDOUT, $nm, $sq);
	 next;
    }
}

