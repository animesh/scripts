$ctg="7180001513595";
$rs=3729;
$re=6566;
while(<>){
	chomp;
	@t=split(/\t/);
	if($ctg eq @t[1]){
	 $start=@t[2];
	 $end=@t[3];
	 if($start>$end){
		$tmp=$start;
		$start=$end;
		$end=$start;
	 }
	 $read{@t[0]}++;
	 if($read{@t[0]}==1){
	  for($c=$start;$c<=$end;$c++){
	 	$depth{$c}++;
	  }
	 }
	}
}
foreach (keys %depth) {
	if($_ >= $rs && $_ <= $re){
		print "$_\t$depth{$_}\n";
	}
}


