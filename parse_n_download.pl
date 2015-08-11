while(<>){
	if(/^[0-9]/){
	chomp;
	@temp=split(/\s+/,);
	$ds="http://predictioncenter.org/casp8/target.cgi?target=".@temp[1]."\\&view=sequence";
	$os= @temp[1].".fas";
	print "@temp[1]\t$ds\n";
	system("curl $ds  > $os ");
	}
}

