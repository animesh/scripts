while(<>){
	chomp;split(/\s+/);
	#print "@_[0]\n";
	push(@posi,@_[0]);
}
for($c=0;$c<=$#posi;$c++){
	if(@posi[$c+1]-@posi[$c]!=1){
		$start=@posi[$c]-$cnt;
		print "$start\t$cnt\t@posi[$c]\n";
		#print "     COD	     $start..@posi[$c]\n";
		$cnt=0;
	}
	elsif(@posi[$c+1]-@posi[$c]==1){
		$cnt++;
	}
}
