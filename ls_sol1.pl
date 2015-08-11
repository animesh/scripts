#!/usr/bin/perl

#print "Hello, World...\n";
$f=shift @ARGV; chomp $f;open F, $f;
$n=0;
while ($l=<F>) {chomp $l;
	
	@temp=split(/\t/,$l);
	print $l;
		for($i=0;$i<=$#temp;$i++){
		$a1[$i][$n]=@temp[$i];
		}
	#print "$l\n";
	$n++;
}
for($a=0;$a<$n;$a++){
		for($b=0;$b<=56;$b++){
#		print "$a1[$a][$b]\t";
		}print "\n"
}