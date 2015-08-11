open(F1,"trimfile.txt");
#open(F1,"tf");
$thresh=200;
while(<F1>){
	chomp;
        $c++;
        $name=$_;
        $name=~s/\s+/\_/g;
	@tmp=split(/\s+/,);        
        $namesubstr=substr($name,9,5);
        $dirstr=uc(substr($name,15,1));
        $libstr=substr($name,0,9);
	$n1=@tmp[0];
	@n2=split(/\_/,$n1);
	$n4=@n2[0];
	if(@tmp[2]>$thresh){
		if($dirstr eq "L"){
			$lp{"$n4.$dirstr"}="$name template=$namesubstr dir=F library=$libstr";
		}
		if($dirstr eq "R"){
			$rp{"$n4.$dirstr"}="$name template=$namesubstr dir=R library=$libstr";
		}
		$ri{$n4}++
	}
}
close F1;


$time=time;
foreach (sort {$ri{$b}<=>$ri{$a}} keys %ri){
	$l="$_.L";
	$r="$_.R";
	@t1=split(/\_/,$lp{$l});
	@t2=split(/\_/,$rp{$r});
		#if($ri{$_}==2){
			print "$_\t$ri{$_}\t$l\t$r\t$lp{$l}\t$rp{$r})\n";
		#}
}


__END__

