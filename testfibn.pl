#!/usr/bin/perl
$x=1;
$f=1;
$lim=shift @ARGV;
while($c<$lim){
	$c++;
	print "$c\t$x\t";
#	$x1=-1*$x2;
	$x1=$x2;
	$x2=$x;
	$x=$x1+$x2;
	$f*=$c;
	$fr=$f/($x/$x2);
	print $x/$x2,"\t$f\t$fr\n";
}


