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
while($l1=<F1>){
	$c1++;$c=$c1-1;chomp $l1;
	if($c1 == 1 || $l1 eq ""){print "Rank\t$l1\n";next;
	}
	@t1=split(/\t/,$l1);
	$key=$c."_".$l1;

	$length=@t1;$N=$length-1;#print "$N\n";
	for($c2=1;$c2<=$#t1;$c2++){
		if($c2<=$all){$temp2+=@t1[$c2];}
		else{$temp3+=@t1[$c2];}
	}
	$temp2=$temp2/$all;
	$temp3=$temp3/$aml;
	for($c2=1;$c2<=$#t1;$c2++){
		if($c2<=$all){$temp4+=($temp2-@t1[$c2])**2;}
		else{$temp5+=($temp3-@t1[$c2])**2;}
	}
	$temp4=sqrt($temp4/$all);
	$temp5=sqrt($temp5/$aml);
	if($temp4 eq $temp5){$temp1=1;}
	else{
		$temp1=($temp2-$temp3)/($temp4+$temp5);
		#$temp1=($temp4);
		}
	$sum{"$key"}=abs($temp1);
	$temp1=0;$temp2=0;$temp3=0;$temp4=0;$temp5=0;$temp6=0;$temp7=0;
}
foreach $q (sort {$sum{$b} <=> $sum{$a}} keys %sum){
	$c3++;@t9=split(/\t/,$q);
	@t10=split(/_/,@t9[0]);
	if($c3<=$top){
		print "$c3\t$q\t$sum{$q}\n";
		}
	}