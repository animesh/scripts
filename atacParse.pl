$file=shift;
open(F,$file);
while($l=<F>){
	chomp $l;
	@tmp=split(/\s+/,$l);
	if(@tmp[1] eq "c"){
		$lenmatdiff=abs(@tmp[6]-@tmp[10]);
		$matlen{@tmp[10]}=@tmp[6];
		$totlen+=@tmp[10];
		#print "$lenmatdiff\t@tmp[6]-@tmp[10]\n";
	}
}

for $key ( sort {$b<=>$a} keys %matlen) {
	$acclen+=$key;
	print "$key\t$matlen{$key}\t$acclen\t$totlen\n";
}
