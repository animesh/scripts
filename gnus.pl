while(<>){
	chomp;
	@t=split(/\s+/,$_);
	if(@t[3] ne "NA" and @t[4] ne "NA" and @t[3] ne "" and @t[4] ne ""){
		$c++;
		$name_gene="\$MIRA$c";
		print "     NEWBLER	     @t[3]..@t[4]\n";
		print "     TEST4	     @t[3]..@t[4]\n";
		push(@name,$name_gene);
	}

}
