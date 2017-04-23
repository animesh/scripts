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
$all=shift @ARGV;chomp $all;
$aml=shift @ARGV;chomp $aml;$top=shift @ARGV;chomp $top;
if ($f1 eq "" or $all eq "" or $aml eq "" or $top eq "") {print "\nUSAGE:	\'perl program_name file no_of_all no_of_aml no_of_feature_2_b_selected\'\n\n";exit;}
open F1,$f1||die"cannot open $f1";
push(@gi,0);
for  ($c0=1;$c0<=$all;$c0++) {
	@gi[$c0]=1;
}
for  ($c0=($all+1);$c0<=($all+$aml+1);$c0++) {
	@gi[$c0]=0;
}
while($l1=<F1>){
	$c1++;$c=$c1-1;chomp $l1;
	if($c1 == 1 || $l1 eq ""){print "Rank\t$l1\n";next;
	}
	@t1=split(/\t/,$l1);
	$key=$c."_".$l1;
	for($c2=1;$c2<=$#t1;$c2++){
		$temp1+=((@t1[$c2]-$gi[$c2])**2);
	}
	$length=@t1;$N=$length-1;
	$temp1=sqrt($temp1);
	$sum{"$key"}=$temp1;
	$temp1=0;$temp2=0;$temp3=0;$temp4=0;$temp5=0;$temp6=0;$temp7=0;
}
foreach $q (sort {$sum{$b} <=> $sum{$a}} keys %sum){
	$c3++;
	if($c3<=$top){
		print "$c3\t$q\t$sum{$q}\n";
		}
	}