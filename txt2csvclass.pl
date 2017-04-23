$input=shift @ARGV;
open(F,$input);
while($l=<F>){
	$l=~s/^\s+//;
	$l=~s/\s+$//;
	@t=split(/\s+/,$l);
	$line++;
	if($line==1){
			for($c=0;$c<$#t;$c++){
				$cp=$c+1;
				print "FC$cp,";
			}
			print "CLASS\n";
	}
	for($c=0;$c<$#t;$c++){
		$out=@t[$c]+0;
		print "$out,";
	}
	$out=@t[$c]+0;
	print "C$out\n";
}
