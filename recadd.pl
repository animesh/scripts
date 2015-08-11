$n= shift @ARGV;
$nb=$n;
if($n<=0){die"$n is less then 1";}

$sum1=iter();
print "$sum1\n";
$n=$nb;$sum=0;
$sum2=rec($nb);
print "$sum2\n";

sub iter {
	while($n>0){
		$sum+=$n;
		$n--;
	}
	return $sum;
}

sub rec {
	$n = shift;
	if($n>0){
		$sum+=($n);
		$n--;
		(rec($n));
   	}
	return $sum;
}
