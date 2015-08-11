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
$f=shift @ARGV;chomp $f;$ftr=shift @ARGV;chomp $ftr;
if (!$f || !$ftr) {print "\nUSAGE:	\'perl program_name FeatureFile_With_OP_Vector No_of_Feature\'\n\n";exit;}
#$row=shift @ARGV;
$m=2;
$iter=100;
$minval=0.001;
$sbcont=1000;
if($row eq "t"){
	open(F,$f)||die"cannot open $f1";
	$c1=0;$rowno=0;
	while($l1=<F>){
		@t1=split(/\s+/,$l1);
		for($c2=0;$c2<=$#t1;$c2++){
			$mat[$c1][$c2]=@t1[$c2]+0;
			}
		$c1++;
	}
	$ft=$f.".t.dat";
	open F1,">$ft";
	for($s1=0;$s1<$c2;$s1++){
		for($s2=0;$s2<$c1;$s2++){
			print F1"$mat[$s2][$s1]\t";
			#$matt[$s1][$s2]=$mat[$s1][$s2];
		}
			print F1"\n";
	}
	close F1;
	open F2,$ft;
	$c1=0;$rowno=0;
	while($l1=<F2>){
	@t1=split(/\s+/,$l1);
	for($c2=0;$c2<=$#t1;$c2++){
		$mat[$c1][$c2]=@t1[$c2]+0;
		}
	$c1++;
	}
	close F2;
	#system("del $ft");
}


else {
	
	open(F,$f);
	$foo=$f.".out";
	open(FO,">$foo");
	$c1=0;$rowno=0;
	while($l1=<F>){
		@t1=split(/\s+/,$l1);
		if($ftr != ""){		
			for($c2=0;$c2<$ftr;$c2++){
				$mat[$c1][$c2]=@t1[$c2]+0;
				}
			for($c3=$ftr;$c3<=$#t1;$c3++){
				$otp[$c1][$c3]=@t1[$c3]+0;
				print FO"$otp[$c1][$c3]\t";
			}
				print FO"\n";

		}
		else{
			for($c2=0;$c2<=$#t1;$c2++){
			$mat[$c1][$c2]=@t1[$c2]+0;
			}
		}
		$c1++;
	}
	close F;
	close FO;
}

#for($s1=0;$s1<$c1;$s1++){
#	for($s2=0;$s2<$c2;$s2++){
#		print "$mat[$s1][$s2]\t";
#		#$matt[$s1][$s2]=$mat[$s1][$s2];
#		}
#		print "\n";
#}
#for($s1=0;$s1<$c1;$s1++){
#	for($s2=$ftr;$s2<=$#t1;$s2++){
#		print "$otp[$s1][$s2]\t";
#		#$matt[$s1][$s2]=$mat[$s1][$s2];
#		}
#		print "\n";
#}
$iterval++;

#generate random matrix
if($iterval==1){
	for($s1=0;$s1<$c1;$s1++){
		for($s2=$c2;$s2<=$#t1;$s2++){
			$otpr[$s1][$s2]=rand(1);
			$cnt+=$otpr[$s1][$s2];
			#print "$otpr[$s1][$s2]\t";
			}
			@sum[$s1]=$cnt;
			$cnt=0;
			#$otpr[$s1][$s2]=abs(1-$cnt);
			#$otpr[$s1][$s2]=rand(1);
			#print "\n";
	}

	#normalise random matrix
	for($s1=0;$s1<$c1;$s1++){
		for($s2=$c2;$s2<=$#t1;$s2++){
			$otprn[$s1][$s2]=$otpr[$s1][$s2]/@sum[$s1];
			$cnt+=$otprn[$s1][$s2];
			#print "$otprn[$s1][$s2]\t";
			}
			#$otpr[$s1][$s2]=abs(1-$cnt);
			#$otpr[$s1][$s2]=rand(1);
			#print "$cnt\n";
			$cnt=0;
	}
	$iterval++;
}
while($iterval<=$iter){

	if($sbcont>=$minval){
		$gcont=GC();
		$edcont=ED();
		$sbcont=SB();
		print "	$minval-$iter: $gcont\t$edcont\t$sbcont \n";
	}
	else{
		print "	$minval-$iter: $gcont\t$edcont\t$sbcont \n";
		PREDI();
		exit;
	}
		$iterval++;
	#generating centroid
	sub GC {
		$gc++;
		for($s1=$c2;$s1<=$#t1;$s1++){#print "$s1\t";
			for($s2=0;$s2<$c2;$s2++){#print "$s2\t";
				for($s3=0;$s3<$c1;$s3++){
					#print "$otprn[$s3][$s1]-$mat[$s3][$s2]\t";
					$val1+=($otprn[$s3][$s1]**$m)*$mat[$s3][$s2];
					$val2+=($otprn[$s3][$s1]**$m);
				}
			if($val2!=0){
				$otprnm[$s2][$s1]=$val1/$val2;
				#print "$otprnm[$s2][$s1]\t$s1-$val1\t$s2-$val2\n";
				$val1=0;$val2=0;
			}
			else{$otprnm[$s2][$s1]=0;}
			}
		}
		return $gc;
	}
		#calculating euclidean distance
	sub ED{
		$ed++;
		for($s3=0;$s3<$c1;$s3++){	$val2=0;
			for($s1=$c2;$s1<=$#t1;$s1++){#print "$s1\t";
				for($s2=0;$s2<$c2;$s2++){#print "$s2\t";
					#print "$otprn[$s3][$s1]-$mat[$s3][$s2]\t";
					$val1+=($otprnm[$s2][$s1]-$mat[$s3][$s2])**2;
					#$val2+=($otprn[$s3][$s1]**$m);
				}
				$ed[$s3][$s1]=($val1);
				$val2+=$ed[$s3][$s1];#print "$val2-$ed[$s3][$s1]\n";
				$val1=0;
			}
			@eda[$s3]=$val2;$val2=0;
		}
		return $ed;
	}				
		#calculating each sample belongingness
	sub SB{
		$fp=$f.".prd";
		open(FP,">$fp");
		$sb++;
		$val1=0;$val2=0;$val3=0;$val4=0;$val5=0;
		for($s3=0;$s3<$c1;$s3++){$val1=0;$val2=0;
			for($s1=$c2;$s1<=$#t1;$s1++){#print "$s1\t";
				for($s2=$c2;$s2<=$#t1;$s2++){#print "$s1\t";
					$otprnmn[$s3][$s1]=($ed[$s3][$s1]/$ed[$s3][$s2])**(2/($m-1));
					$val1+=$otprnmn[$s3][$s1];
					#$otprnmn[$s3][$s1]=1/$otprnmn[$s3][$s1];
					#print "$otprnmn[$s3][$s1] - $ed[$s3][$s1] / @eda[$s3]\n";
					#$otprn[$s3][$s1]=($ed[$s3][$s1]/@eda[$s3])**(2/($m-1));
				}
				$val1=1/$val1;$val2+=$val1;
				$val3=abs($otprn[$s3][$s1]-$val1);
				$val4+=$val3;
				$otprn[$s3][$s1]=$val1;
				print FP"$val1\t";
				$val1=0
			}
			print FP"\n";$val1=0;
		}
		$val5=$val4/(($s1-$c2)*$s3);
		close FP;
		return $val5;
	}
}

sub PREDI{
$f1=$foo;
$f2=$fp;
open(F1,$f1);
open(F2,$f2);
undef @cmp1;undef @cmp2;$c1=0;$c2=0;$c3=0;
while($l1=<F1>){chomp $l1;
@t1=split(/\s+/,$l1);
		for($c1=0;$c1<=$#t1;$c1++){
			$h1{@t1[$c1]}=($c1+1);
			if(@t1[$c1]>$m1){
				$m1=@t1[$c1];
				}
		}
		push(@cmp1,$h1{$m1});$m1=0;undef %h1;
}
close F1;
while($l2=<F2>){chomp $l2;
@t2=split(/\s+/,$l2);
		for($c2=0;$c2<=$#t2;$c2++){
			$h2{@t2[$c2]}=($c2+1);
			if(@t2[$c2]>$m2){
				$m2=@t2[$c2];
				}
		}
		push(@cmp2,$h2{$m2});$m2=0;undef %h2;
}
close F2;		
print "Sample#\tActual\tObtained\n";
for($c2=0;$c2<=$#cmp2;$c2++){$c5=$c2+1;
	$mct{@cmp1[$c2]}++;
	if(@cmp1[$c2]!=@cmp2[$c2]){
		$mc{@cmp1[$c2]}++;
		print "$c5\t@cmp1[$c2]\t@cmp2[$c2]\n";
		$c3++;
	}
	else{
		#$mc{@cmp1[$c2]}++;
		#print "$c5\t@cmp1[$c2]\t@cmp2[$c2]\n";
	}
}

print "\nCLASS\tMISCLASSIFICATION: TOTAL MEMBERS\tPERCENT\n";

for($c10=1;$c10<=$c1;$c10++){
	if($mct{$c10}==0 or $mc{$c10}==0){
		$per=0;
		print "$c10\t0\t\t : $mct{$c10}\t\t\t$per\n";
	}
	else{
	$per=$mc{$c10}/$mct{$c10}*100;
	print "$c10\t$mc{$c10}\t\t : $mct{$c10}\t\t\t$per\n";
	}
}
$tper=($c3/$c5)*100;
print "\nTotal Misclassification\t-> $c3 : $c5\t\t$tper\n";
}