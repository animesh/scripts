$file2=shift @ARGV;
open(F2,$file2);
$fout="$file2.class.csv";
open(FO,">$fout");
while($l=<F2>){
	chomp $l;
	$l=~s/^\s+//;
	$l=~s/\s+$//;
	@t=split(/\s+/,$l);
	$line++;
	if($line==1){
			for($c=0;$c<$#t;$c++){
				$cp=$c+1;
				print FO"V$cp,";
			}
			print FO"CLASS\n";
	}
	for($c=0;$c<$#t;$c++){
		$out=@t[$c]+0;
		print FO"$out,";
	}
	$out=@t[$c]+0;
	print FO"C$out\n";
	print "$line Class $out $c\n";
}
close FO;
close F2;

