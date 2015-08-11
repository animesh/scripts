#!/usr/bin/perl
$f=shift @ARGV;
open(F,$f);
while($l=<F>){
	if($l=~/^>/){$l=~s/\>|\s+|\n|\t//g;$sn.=$l;}
	else{$seq.=$l}
}
open(FO,">$f.pir");
print FO">P1\;$sn\nsequence\:$sn\:\:\:\:\:\:\:0.00\: 0.00\n$seq\n*\n";
