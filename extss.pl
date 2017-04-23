#!/usr/bin/perl
$f=shift @ARGV;
$s=shift @ARGV;
$e=shift @ARGV;
chomp $f,$e,$s;
open(F,$f);
while($l=<F>){
	chomp $l;
	if($l=~/^>/){$l=~s/\>|\s+|\n|\t//g;$sn.=$l;}
	else{$seq.=$l}
}
open(FO,">$f.ss");
$ss=substr($seq,$s+1,$e-$s);
$lms=length($seq);
print "$sn\t$seq\t$s\t$e\t$lms\n";
print FO">$sn\n$ss\n";

