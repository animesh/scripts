while(<>){
	chomp;
	@t=split(/\t/);
	@tt=split(/\-/,@t[5]);
	if($t[0]>80 && (@t[4]/@tt[0]>0.9 && @t[4]/@tt[0]<1.1)){print "@t[0]\t@t[4]\t@t[5]\t@t[6]\t@t[7]\n";}
		
}
