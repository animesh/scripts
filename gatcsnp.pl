while(<>){
	chomp;
	@t=split(/\s+/);
	$lp=$l;
	$l++;
	my $gl;
	my $glp;
	for($c=0;$c<=$#t;$c++){
		if($l-$lp>1){print "STEP";}
		if(@t[$c]=~/^gi/){
			#print "$l,@t[$c]\t";
			$gl.=@t[$c];
		}
		if(@t[$c]=~/^[1-9]/){
			#print "$l,@t[$c]\t";
			$glp.=@t[$c];
		}
	}
	$glh{$gl}=$glp;
	print "\n";
}
foreach $w (keys %glh){print "$w\t$glh{$w}\n"};
