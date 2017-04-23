while(<>){
	chomp;
	split(/\s+/);
	push(@tmp,@_);
}
for($c=0;$c<=$#tmp;$c++){
	print @tmp[$c],":e $c\t";
}
