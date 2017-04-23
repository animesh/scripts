$file=shift @ARGV;
open(F,$file);
while($l=<F>){
	chomp $l;
	if($l=~/^Flowgram/){
		$c++;
		@temp=split(/\:/,$l);
		@temp2=split(/\s+/,$temp[1]);
		$length=(@temp2);
		$length-=1;
		for($c2=0;$c2<$#temp2;$c2++){
			$c3=$c2+1;
			$p0=int($temp2[$c3]);
			$p1=$temp2[$c3]-$p0;
			if($p1>0.5){
				$p1=1-$p1;
			}
			$p1=sprintf("%.2f", $p1);
			print "$temp2[$c3]\n";
		}
		#print "$c\t$temp2[1]\t$length\n";
	}
}
