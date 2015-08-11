#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Code base of Animesh Sharma [ sharma.animesh@gmail.com ]

#!/usr/bin/perl
$f=shift @ARGV;
open(F,$f);$r=0;
while($l=<F>){chomp $l;$l=uc($l);
	if(($l!~/^>/) and ($l ne "")){
		@t=split(//,$l);
		for($c=0;$c<=$#t;$c++){
			$w[$r][$c]=(@t[$c]);
		}
		$r++;
	}
}
close F;
for($r1=0;$r1<$c;$r1++){
	for($c1=0;$c1<$r;$c1++){
		$m{$w[$c1][$r1]}++;
		#print "$w[$c1][$r1]\t";
	}
	foreach $w (keys %m){
		$prob=($m{$w}/$r);
		$plog=0-$prob*(log($prob)/log(2));
		$p+=$plog;
		#print "$r\t$w\t$m{$w}\t$prob\t$plog\n";
		}
	undef %m;
	print "$p\n";$p=0
}
#	foreach $w (sort {$a <=> $b} keys %m){print "$w\t$m{$w}\n";}
foreach $q (sort {$sum{$b} <=> $sum{$a}} keys %sum){
	$c3++;@t=split(/\s+/,$q);@t=split(/\_/,@t[2]);
	#if(($c3<=$top) and ($cls{@t[3]}<=6)){
	if(($cls{@t[3]}<=$top)){
		print "$c3\t$sum{$q}\t$q\n";$cls{@t[3]}++;
		}
}