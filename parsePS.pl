while(<>){
	chomp;
	@t=split(/\t/);
	if(@t[1] eq "NoThreshold"){
		print "@t[0]\t@t[2]\n";
		@ln=split(/\-/,@t[0]);
		$libname=@ln[0];
		$dist=@t[2];
		system("perl genpairalllib.pl 454AllContigs.fna $libname $dist"); 
	}
}

