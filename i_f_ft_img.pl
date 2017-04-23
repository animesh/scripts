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
$row=shift @ARGV;
$file1=$f."_ft.pgm";
$file2=$f."_invft.pgm";
open(F,$f);
if($row eq "pgm"){
open(F1,">$file1");
open(F2,">$file2");
}
use Math::Complex;
$pi=pi;
$i=sqrt(-1);
$c1=0;$rowno=0;
while($l1=<F>){
	chomp $l1;
	if($row eq "pgm" and $rowno<=3){$rowno++;print F1"$l1\n";print F2"$l1\n";next;}
	@t1=split(/\s+/,$l1);
	for($c2=0;$c2<=$#t1;$c2++){
		if($c1==0 or $c2==0){$mat[$c2][$c1]=@t1[$c2]+0;}
		else{$mat[$c1][$c2]=(@t1[$c2])+0;}#print "@t1[$c2]  ";
		}
	
	$c1++;
}
#print "$c1\t$c2\n";
for($c6=0;$c6<$c1;$c6++){
	for($c5=0;$c5<$c2;$c5++){
		$subsum=0;
		$u=$c5;
		#print "$mat[0][$c6]\t$mat[$c5][0]\t$val\t";
		for($c7=0;$c7<$c2;$c7++){
			$val=($mat[$c6][$c7]+0)*((-1)**($c1+$c2));		
			$N=$c2;
			$x=$c7;
			$subsum+=($val*exp(-(2*$pi*$i*($u*$x)/$N)));
			#print "$val\t2PI I $x $u $N\t";
		}
		#print "\n";
		#$subsumtotal+=(((1/$le)**2)*(abs($subsum)**2));
		$subsuma=(1/$N)*(($subsum));
		#print "$mat[0][$c6]\t$mat[$c5][0]\t$val\t$subsum\t$subsuma\n";
		#print "$subsuma\t";
		$matt[$c6][$c5]=$subsuma;
		#print "$subsuma\t";
	}
	#print "\n";
}
print "$c1\t$c2\n";
for($c9=0;$c9<$c2;$c9++){
	for($c10=0;$c10<$c1;$c10++){
		$subsum=0;
		$u=$c10;
		#print "$matt[$c9][$c10]\t$matt[$c10][$c9]\t";
		for($c7=0;$c7<$c1;$c7++){
			#$val=i;
			$val=($matt[$c7][$c9]);
			#print "$val\t$matt[$c10][$c9]\t";
			$N=$c1;
			$x=$c7;
			$subsum+=($val*exp(-(2*$pi*$i*($u*$x)/$N)));
			#print "$mat2[$c7][$c6]\t2PI I $x $u $N\t";
			#print "$c6\t$c7\t";
		}
		#print "\n";
		#$subsumtotal+=(((1/$le)**2)*(abs($subsum)**2));
		$subsuma=(1/$N)*(($subsum));
		#print "$mat[0][$c6]\t$mat[$c5][0]\t$val\t$subsum\t$subsuma\n";
		$mattt[$c10][$c9]=$subsuma;
		#print "$mattt[$c7][$c9]\t";
		if($row eq "pgm"){
			$subsumm=abs($subsuma);
			$subsumm = int($subsumm);
			print F1"$subsuma ";
		}
		else{print "$subsuma\t";}
	}
	print "\n";
		if($row eq "pgm"){
		print F1"\n";
		}

}

for($c9=0;$c9<$c2;$c9++){
	for($c10=0;$c10<$c1;$c10++){
		$subsum=0;
		$u=$c10;
		#print "$mattt[$c10][$c9]\t";
		for($c7=0;$c7<$c1;$c7++){
			$val=$mattt[$c7][$c9];
			#print "$val\t";
			$N=$c1;
			$x=$c7;
			$subsum+=($val*exp((2*$pi*$i*($u*$x)/$N)));
			#print "$val\t2PI I $x $u $N\t";
			#print "$c6\t$c7\t";
		}
		#print "\n";
		#$subsumtotal+=(((1/$le)**2)*(abs($subsum)**2));
		$subsuma=(($subsum));
		#print "$mat[0][$c6]\t$mat[$c5][0]\t$val\t$subsum\t$subsuma\n";
		#print "$subsuma\t";
		$matttt[$c10][$c9]=$subsuma;
	}
	#print "\n";
}
for($c6=0;$c6<$c1;$c6++){
	for($c5=0;$c5<$c2;$c5++){
		$subsum=0;
		$u=$c5;
		#print "$mat[0][$c6]\t$mat[$c5][0]\t$val\t";
		for($c7=0;$c7<$c2;$c7++){
			#$val=($matttt[$c6][$c7]+0)*((-1)**($c1+$c2));		
			$N=$c2;
			$x=$c7;
			$val=($matttt[$c6][$c7]);
			$subsum+=($val*exp((2*$pi*$i*($u*$x)/$N)));
			#print "$val\t2PI I $x $u $N\t";
		}
		#print "\n";
		#$subsumtotal+=(((1/$le)**2)*(abs($subsum)**2));
		$subsuma=(($subsum)*((-1)**($c1+$c2)));
		$subsumm=abs($subsuma);
		#print "$mat[0][$c6]\t$mat[$c5][0]\t$val\t$subsum\t$subsuma\n";
		#print "$subsuma\t";
		$mattttt[$c6][$c5]=$subsuma;
		if($row eq "pgm"){
		$subsumm = int($subsumm);
		print F2"$subsumm ";
		}
		else{print "$subsumm\t"}
	}
		if($row eq "pgm"){
		print F2"\n";
		}

	print "\n";
}