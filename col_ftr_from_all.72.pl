@files=<IC_*_toML.txt.class.arff.72fold.lr.txt>;
for($c=0;$c<=$#files;$c++) {
        $file=@files[$c];
        #print "Processing file # $c $file,"; 
	@fname=split(/\./,$file);
	print "@fname[0],";
	open(F,$file);
	while(<F>){
		chomp;
		@t1=split(/\s+/);
		for($cc=0;$cc<=$#t1;$cc++) {
			if(@t1[$cc]=~/^FC/){
				push(@tall,@t1[$cc]);
			}
		}
	}
	close F;
	@utall = grep !$seen{$_}++, @tall;
	print join(",",@utall),"\n";
	undef @tall;
	undef @utall;
}
