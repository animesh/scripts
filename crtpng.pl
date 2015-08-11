#!/usr/bin/perl
$file=shift @ARGV;
open(F,$file);
while($l=<F>){
	$c++;
	chomp $l;
	@t=split(/\s+/,$l);
	push(@flist,@t[1]);
	if($max<@t[1]){$max=@t[1]}
	print "$c\t@t[1]\t$max\n";
}
$fo=$file.".pgm";
open(FO,">$fo");
$time=time;
$csqrt=int(sqrt($c));
print FO"P2\n# Created by crtpng.pl at $time\n$csqrt $csqrt\n255\n";
for($c1=0;$c1<$csqrt;$c1++){
	for($c2=0;$c2<$csqrt;$c2++){
		$val=int(@flist[$c1*$csqrt+$c2]/$max*255);
		print FO"$val ";
	}
	print FO"\n";
}

