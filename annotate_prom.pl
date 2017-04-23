while(<>){
        chomp;
	$c++;
        if($c<6){next}
        else{
		@tmp=split(/\s+/,$_);
		$s=@tmp[2];
		$e=@tmp[2]+100;
		if(@tmp[3] eq "F"){print"\tpromoter\t$s..$e\n";}
		elsif(@tmp[3] eq "R"){print"\tpromoter\t$e..$s\n";}
                print"\t\t\/gene\=\"Promoter @tmp[1]\"\n";
                print"\t\t\/SECDrawAs\=\"Region\"\n";
	}
}
