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
$f1=shift @ARGV;chomp $f1;
open F1,$f1||die"cannot open $f1";

while($l1=<F1>){
	chomp $l1;
	#$c1++;$c=$c1-1;#if($c1 == 1 || $l1 eq ""){print "Rank\t$l1\n";next;}
	@t1=split(/\s+/,$l1);
	for($c2=0;$c2<=$#t1;$c2++){
		(
		$mat[$c2][$c1]=(@t1[$c2]);
		}
	
	$c1++;
}
for($c5=0;$c5<$c2;$c5++){
	for($c6=0;$c6<($c1-1);$c6++){
		print "$mat[$c5][$c6]\t";
		}
	print "$mat[$c5][$c6]\n";
}	

}

foreach $q (sort {$sum{$b} <=> $sum{$a}} keys %sum){
	$c3++;
	if($c3<=$top){
		print "$c3\t$q\t$sum{$q}\n";
		}
	}

sub PR
{
	@t1=split(/\t/,$l1);
	$key=$c."_".$l1;
	for($c2=1;$c2<=$#t1;$c2++){
		$temp1+=(@t1[$c2]*$gi[$c2]);
		$temp2+=@t1[$c2];
		$temp3+=$gi[$c2];
		$temp4+=(@t1[$c2]**2);
		$temp5+=($gi[$c2]**2);
	}
	$length=@t1;$N=$length-1;#print "$N\n";
	$temp6=$temp2**2;
	$temp7=$temp3**2;#$t9=sqrt(($temp4-($temp6/$N))*($temp5-($temp7/$N)));
	$temp1=($temp1-(($temp2*$temp3)/$N))/(sqrt(($temp4-($temp6/$N))*($temp5-($temp7/$N))));
	$sum{"$key"}=abs($temp1);
	$temp1=0;$temp2=0;$temp3=0;$temp4=0;$temp5=0;$temp6=0;$temp7=0;
}