$file=shift;
open(F,$file);
while($l=<F>){
        chomp $l;
        @tmp=split(/\s+/,$l);
        if(@tmp[1] eq "c"){
                $lenmatdiff=abs(@tmp[6]-@tmp[10]);
                $lenmatch=int(@tmp[6]+@tmp[10]/2);
		if(@tmp[6]<@tmp[10]){$small=@tmp[6]}
		else{$small=@tmp[10]}
		$totlen+=$small;
                $matscaf{"@tmp[4]-@tmp[8]"}+=$small;
                #print "$lenmatdiff\t@tmp[6]-@tmp[10]\n";
        }
}

foreach $key ( sort { $matscaf{$b} <=> $matscaf{$a} } keys %matscaf) {
        $acclen++;
	$totlenn+=$matscaf{$key};
	$per=100*($totlenn/$totlen);
        print "$acclen\t$key\t$matscaf{$key}\t$totlenn\t$totlen\t$per\n";
}

