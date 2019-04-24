while(<>){
	chomp;
        $c++;
	if($c==1){next}
	@tmp=split(/\t/,);        
        $template=@tmp[0];
        $status=@tmp[1];
        $leftid=@tmp[3];
        $rightid=@tmp[6];
        $leftd=@tmp[8];
        $rightd=@tmp[9];
	$ri{"$leftid - $rightid"}++;
	$rit{"$leftid - $rightid"}.="$template\t";
	#if("$leftid - $rightid" eq "Repeat - Repeat"){print "$_\n";}
	
}

open(FO1,">connectedcontigs.txt");
open(FO2,">connectedcontigsgraph.txt");


foreach (sort {$ri{$b}<=>$ri{$a}} keys %ri){
		$name=$rit{$_};
		$name=~s/\s+//g;
		if($name ne ""){
			print FO1"$_\t$ri{$_}\t$rit{$_}\n";
			@tmp=split(/\s+|\-/,);
			$l=@tmp[0];
			$r=@tmp[3];	
			$l=~s/contig//g;
			$r=~s/contig//g;
			$l=~s/Repeat/0/g;
			$r=~s/Repeat/0/g;
			$r+=0;$l+=0;
			print FO2"$l\t$r\t$ri{$_}\n";
		
		}
}


__END__

