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
open(F,$f);

if($row eq "pgm"){
$file1=$f."_ft.pgm";
$file2=$f."_invft.pgm";
open(F1,">$file1");
open(F2,">$file2");
}

if($row eq ""){
$file1=$f."_ft.dat";
$file2=$f."_invft.dat";
open(F1,">$file1");
open(F2,">$file2");
}

use Math::Complex;
$pi=pi;
$i=sqrt(-1);
$c1=0;$rowno=0;
while($l1=<F>){
	chomp $l1;
	if($row eq "pgm" and $rowno<=3){
		if(($rowno==0) and ($l1!~/^P2/)){die "invalid PGM file $file";}
		if($rowno==2){@rc=split(/\s+/,$l1);}
		$rowno++;print F1"$l1\n";print F2"$l1\n";next;
		}
	if($row eq "pgm" and $rowno>3){
		$str=$str." $l1";
		next;
		}
	@t1=split(/\s+/,$l1);
	for($c2=0;$c2<=$#t1;$c2++){
		if($c1==0 or $c2==0){$mat[$c1][$c2]=cplx(@t1[$c2]);}
		else{$mat[$c1][$c2]=cplx(@t1[$c2]);}#print "@t1[$c2]  ";
		}
	
	$c1++;
}
if($row eq "pgm"){$c1=@rc[0];$c2=@rc[1];@rcn=split(/\s+/,$str);
	for($s1=0;$s1<$c1;$s1++){
		for($s2=0;$s2<$c2;$s2++){
			$mat[$s1][$s2]=@rcn[$s1*$c1+$s2];
		}
	}
	#die "invalid PGM file $file";
}

#print "$c1\t$c2\n";
for($c6=0;$c6<$c1;$c6++){
	for($c5=0;$c5<$c2;$c5++){
		$subsum=0;
		$u=$c5;
		#print "$mat[0][$c6]\t$mat[$c5][0]\t$val\t";
		for($c7=0;$c7<$c2;$c7++){
			$val=($mat[$c6][$c7]+0)*((-1)**($c7+$c6));		
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
		#$subsumm=abs($subsuma);
		$subsumm = int($subsuma);
		print F1"$mattt[$c10][$c9]\t";#print F1"$subsumm\t";
		#print "$subsuma\t";

	}
	#print "\n";
	print F1"\n";
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
			$val=($matttt[$c6][$c7]+0);		
			$N=$c2;
			$x=$c7;
			$val=($matttt[$c6][$c7]);
			$subsum+=($val*exp((2*$pi*$i*($u*$x)/$N)));
			#print "$val\t2PI I $x $u $N\t";
		}
		#print "\n";
		#$subsumtotal+=(((1/$le)**2)*(abs($subsum)**2));
		$subsuma=(($subsum))*((-1)**($c5+$c6));
		#$subsumm=abs($subsuma);
		#print "$mat[0][$c6]\t$mat[$c5][0]\t$val\t$subsum\t$subsuma\n";
		#print "$subsuma\t";
		$subsumm = int($subsuma);
		$mattttt[$c6][$c5]=$subsumm;
		#print F2"$subsumm\t";
		#print "$subsuma\t";
	}
	#print F2"\n";
	#print "\n";
}
print "$c1\t$c2\n";
for($s1=0;$s1<$c1;$s1++){
	for($s2=0;$s2<$c2;$s2++){
		print F2"$mattttt[$s1][$s2]\t";
	}
		print F2"\n";
}
