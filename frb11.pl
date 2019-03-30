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
if((@ARGV)!=3){die "USAGE: progname training_file test_file feature\n";}
$choose="cen";
#$choose="memval";
$f=shift @ARGV;
$ft=$f;
$ftt=shift @ARGV;
$ftr=shift @ARGV;
$m=2;
$iter=10;
$minval=0.0001;
#$minval=shift @ARGV;
$sbcont=1000;
$clusd=2;
$eta=0.05;
$etan=0.3;
$etas=0.3;
$thresh=0.0001;
$misclasst=1;
READDATA($f);
CLUSTERING($f);
TRAINING($f);
TEST($ftt);
#LEARN();
sub TRAINING{
	$ft=shift;
	if($ftr != "") {$rowt=0;
		open(FT,$ft);
		while($l1=<FT>){
			@t1=split(/\s+/,$l1);
				for($c2=0;$c2<$ftr;$c2++){
					$mattrain[$rowt][$c2]=@t1[$c2]+0;
					}
				for($c3=$ftr;$c3<=$#t1;$c3++){
					$otptrain[$rowt][$c3]=@t1[$c3]+0;
					if($otptrain[$rowt][$c3]==1){$label=$c3-$ftr;}
				}
			$train{$rowt}=$label;
			#print "$rowt\t$train{$rowt}\n";
			$rowt++;$label=0;
		}
		close FT;
	}
	LEARN($ft,$iter);
}

sub TEST{
	$ftt=shift;
	if($ftr != "") {$rowt=0;
		open(FTT,$ftt);
		while($l1=<FTT>){
			@t1=split(/\s+/,$l1);
				for($c2=0;$c2<$ftr;$c2++){
					$mattrain[$rowt][$c2]=@t1[$c2]+0;
					}
				for($c3=$ftr;$c3<=$#t1;$c3++){
					$otptrain[$rowt][$c3]=@t1[$c3]+0;
					if($otptrain[$rowt][$c3]==1){$label=$c3-$ftr;}
				}
			$train{$rowt}=$label;
			#print "$rowt\t$train{$rowt}\n";
			$rowt++;$label=0;
		}
		close FTT;
	}
	LEARN($ftt,0);
}

sub LEARN{$avgerr=$rowt*$ftr;$literval=0;$misnas=$rowt;$ft=shift;$iter=shift;
	while(($literval<=$iter) and ($avgerr>=$thresh) and ($misnas>$misclasst)){
		$maxerrold=$maxerr;$maxerr=0;$misnasold=$misnas;$misnas=0;
		$ftres=$ft.".test.out";
		open(FTR,">$ftres");
		print FTR"Data\#\tRealClass-SubClus\tMisClass-Subclus\n";
		for($a0=0;$a0<$rowt;$a0++){
			$maxa=0;$maxna=0;$maxacol=0;$maxnacol=0;
			for($a1=0;$a1<=$#lab;$a1++){
				for($a2=0;$a2<$clusd;$a2++){
					$firingst=1;
					if(($exist{"$a1-$a2"}!=1) and ($exist{"$a1-$a2"}!=0)){
						for($a3=0;$a3<$ftr;$a3++){
								$firingst*=(1/exp((($mattrain[$a0][$a3]-$trainvalcen[$a1][$a2][$a3])**2)/($trainvalstd[$a1][$a2][$a3]**2)));
						}
					}
					if($train{$a0}==$a1 and $firingst>=$maxa){
						$maxa=$firingst;$maxacol="$a1-$a2";
					}
					elsif($train{$a0}!=$a1 and $firingst>=$maxna){
						$maxna=$firingst;$maxnacol="$a1-$a2";
					}
					else{#print "I Dunno\n";
					}
				}
				for($a2=0;$a2<$clusd;$a2++){
					for($a3=0;$a3<$ftr;$a3++){
						if(($train{$a0}==$a1) and (($exist{"$a1-$a2"}!=1) and ($exist{"$a1-$a2"}!=0))){
							$trainvalcen[$a1][$a2][$a3]+=$etan*(1-$maxa+$maxna)*($maxa/($trainvalstd[$a1][$a2][$a3]**2))*($mattrain[$a0][$a3]-$trainvalcen[$a1][$a2][$a3]);
							$trainvalstd[$a1][$a2][$a3]+=$etas*(1-$maxa+$maxna)*($maxa/($trainvalstd[$a1][$a2][$a3]**3))*(($mattrain[$a0][$a3]-$trainvalcen[$a1][$a2][$a3])**2);
						}
						elsif(($exist{"$a1-$a2"}!=1) and ($exist{"$a1-$a2"}!=0)){
							$trainvalcen[$a1][$a2][$a3]-=$etan*(1-$maxa+$maxna)*($maxna/($trainvalstd[$a1][$a2][$a3]**2))*($mattrain[$a0][$a3]-$trainvalcen[$a1][$a2][$a3]);
							$trainvalstd[$a1][$a2][$a3]-=$etas*(1-$maxa+$maxna)*($maxna/($trainvalstd[$a1][$a2][$a3]**3))*(($mattrain[$a0][$a3]-$trainvalcen[$a1][$a2][$a3])**2);
						}
						#print FCC"$trainvalcen[$a1][$a2][$a3]\t";
					}
					#print "$ct[$a0][$a1][$a2]\n";
					#print FCC"$a1\t$a2\t$maxa-$maxna\t";
				}

			}
			#if(($exist{"$a1-$a2"}!=1) and ($exist{"$a1-$a2"}!=0)){
				if(($maxa<$maxna)){$misnas++;}
				#print FCC"$a0\t$maxa-$maxna\t$misnas\t$maxerr\n";
				$maxerr+=((1-$maxa+$maxna)**2);
			#}
			print FTR"$a0\t$maxacol [$maxa]\t\t\t$maxnacol [$maxna]\t\t";
			if(($maxa<$maxna)){print FTR"Misclassified [Actual-$maxacol\tPredicted-$maxnacol]\t$misnas\n";}
			else{print FTR"\n";}
		}
		$avgerr=$maxerr/($rowt*$ftr);
		print "$literval\t$avgerr\t$misnas\n";
		if(($misnasold<$misnas) or ($maxerrold<$maxerr)){
			$etas=(1-$eta)*$etas;
			$etan=(1-$eta)*$etan;
		}
		$literval++;
	}
}



sub READDATA{
	$f=shift;
	if($ftr != "") {
		open(F,$f);
		$foo=$f.".out";
		#open(FO,">$foo");
		$c1=0;$rowno=0;
		while($l1=<F>){
			@t1=split(/\s+/,$l1);
				for($c2=0;$c2<$ftr;$c2++){
					$matold[$c1][$c2]=@t1[$c2]+0;
					}
				for($c3=$ftr;$c3<=$#t1;$c3++){
					$otp[$c1][$c3]=@t1[$c3]+0;
					if($otp[$c1][$c3]==1){$label=$c3-$ftr+1;}
					#print FO"$otp[$c1][$c3]\t";
				}
					#print FO"\n";
			$row=$c1+1;
			$labhash{$row}=$label;
			$clsno{$label}++;
			push(@lab,$label);
			$c1++;$label=0;
		}
		close F;
		close FO;
	}
	%seen=();
	@lab = (grep{ !$seen{$_} ++} @lab);#undef @all;
	@lab = (sort {$a <=> $b} @lab);
	$elem=0;
	$totelem=0;
}

sub CLUSTERING{
	$f=shift;
	$foc=$f.".clust.txt";
	open(FCC,">$foc");
	for($a1=0;$a1<=$#lab;$a1++){
		$elem=$clsno{@lab[$a1]};
		for($c1=0;$c1<$elem;$c1++){
			if($labhash{($c1+$totelem+1)} eq @lab[$a1]){
				for($c2=0;$c2<$ftr;$c2++){
					$mat[$c1][$c2]=$matold[($c1+$totelem)][$c2];
				}
			}
		}
		$totelem+=$clsno{@lab[$a1]};
		$retfrm=INITIALIZE($choose);

		$classnumber=$a1+1;

	#Finding the Maxcol from Sample Belonginness
			for($s1=0;$s1<$c1;$s1++){$max=0;$maxcol=$s2;
				for($s2=0;$s2<$clusd;$s2++){
					if($otprn[$s1][$s2]>$max){
						$max=$otprn[$s1][$s2];$maxcol=$s2;
					}
				}
				$maxcolhash{$maxcol}++;$maxcolsam{$s1}=$maxcol;	
			}

	#Finding the Mean,Variance and Sample Belonginness and storing in 3 dimensional array
			foreach(sort keys %maxcolhash){$_=$_+0;
				for($s2=0;$s2<$ftr;$s2++){
					for($s1=0;$s1<$c1;$s1++){
						if($_ ==$maxcolsam{$s1}){
							$meanval+=$mat[$s1][$s2];$N++;
						}
					}
				$meanval{$s2}=$meanval/$N;
				$meanval=0;$N=0;
				}$exists=1;
				for($s2=0;$s2<$ftr;$s2++){
					for($s1=0;$s1<$c1;$s1++){
						if($_ ==$maxcolsam{$s1}){
							$stddevval+=($mat[$s1][$s2]-$meanval{$s2})**2;$N++;
							$stddevvalsb+=($mat[$s1][$s2]-$otprnm[$s2][$_])**2;
						}
					}
					$stddevval{$s2}=sqrt($stddevval)/$N;
					$stddevvalsb{$s2}=sqrt($stddevvalsb)/$N;
					$stddevval=0;$N=0;$stddevvalsb=0;
					#print "$meanval{$s2}\t";#$otprnm[$s2][$_]\t$stddevval{$s2}\t$stddevvalsb{$s2}\t";#$stddevval{$s2}\t
					$trainvalmean[$a1][$_][$s2]=$meanval{$s2};
					$trainvalstd[$a1][$_][$s2]=$stddevval{$s2};
					$trainvalcen[$a1][$_][$s2]=$otprnm[$s2][$_];
					$trainvalstdcen[$a1][$_][$s2]=$stddevvalsb{$s2};
					$exists*=$trainvalstd[$a1][$_][$s2];
					print FCC"$trainvalcen[$a1][$_][$s2]\t";
				}
				$exist{"$a1-$_"}=$exists;
				print FCC"$a1\t$_\t$maxcolhash{$_}\t$exist{\"$a1-$_\"}\n";
				print "$a1\t$_\t$maxcolhash{$_}\t$exist{\"$a1-$_\"}\n";
			}
			undef %maxcolhash;undef %maxcolsam;
			undef %stddevvalsb;undef %stddevval;
			undef %meanval;#undef %stddevval;

	}
}
#foreach(sort {$a<=>$b} @lab){print "$_\t$clsno{$_}\n";}
sub INITIALIZE{
	$choose=shift;
	$iterval=0;
	$sbcont=$minval+1;
	$gc=0;
	$sb=0;
	$ed=0;
	$gcont=0;
	$edcon=0;
	#generate random matrix
		if($iterval==0 and $choose eq "memval"){
			for($s1=0;$s1<$c1;$s1++){
				for($s2=0;$s2<$clusd;$s2++){
					$otpr[$s1][$s2]=rand(1);
					$cnt+=$otpr[$s1][$s2];
					}
					@sum[$s1]=$cnt;
					$cnt=0;

			}

			#normalise random matrix
			for($s1=0;$s1<$c1;$s1++){
				for($s2=0;$s2<$clusd;$s2++){
					$otprn[$s1][$s2]=$otpr[$s1][$s2]/@sum[$s1];
					$cnt+=$otprn[$s1][$s2];
					#print "$otprn[$s1][$s2]\t";
					}
					#print "$otprn[$s1][$s2]\n";
					$cnt=0;
			}
			$iterval++;
		}

		elsif($iterval==0 and $choose eq "cen"){
			for($s1=0;$s1<$clusd;$s1++){$s3=int(rand($elem-1));
				for($s2=0;$s2<$ftr;$s2++){
					$otprnm[$s2][$s1]=$mat[$s3][$s2];#print FCC"$otprnm[$s2][$s1]\t";
				}
				#print FCC"$s3\t";
			}
			$iterval++;
		}

	while($iterval<=$iter){

		if($sbcont>=$minval){
			if($choose eq "memval"){
				$gcont=GC();
				$edcont=ED();
				$sbcont=SB();
				print "$choose:	$minval-$iter: $gcont\t$edcont\t$sbcont \n";
			}
			if($choose eq "cen"){
				$edcont=ED();
				$sbcont=SB();
				$gcont=GC();
				print "$choose:	$minval-$iter: $gcont\t$edcont\t$sbcont \n";
			}
		}
		else{
			#print "	$minval-$iter: $gcont\t$edcont\t$sbcont \n";
			#PREDI();
			$iterval=$iter+1;
		}
			$iterval++;

	}
	return("$iterval");
}
	#generating centroid
	sub GC {
		$gc++;
		for($s1=0;$s1<$clusd;$s1++){
			for($s2=0;$s2<$ftr;$s2++){
				for($s3=0;$s3<$c1;$s3++){
					$val1+=($otprn[$s3][$s1]**$m)*$mat[$s3][$s2];
					$val2+=($otprn[$s3][$s1]**$m);
				}
			if($val2!=0){
				$otprnm[$s2][$s1]=$val1/$val2;
				$val1=0;$val2=0;
			}
			else{
				$otprnm[$s2][$s1]=0;
				}
			}
		}
		return $gc;
	}
		#calculating euclidean distance
	sub ED{
		$ed++;
		for($s3=0;$s3<$c1;$s3++){	$val2=0;
			for($s1=0;$s1<$clusd;$s1++){
				for($s2=0;$s2<$ftr;$s2++){
					$val1+=($otprnm[$s2][$s1]-$mat[$s3][$s2])**2;
					#if($val1==0){print "\t$s3\t$s1\t$s2\t$otprnm[$s2][$s1]\t$mat[$s3][$s2]\n"}
				}
				#$ed[$s3][$s1]=($val1);
				$ed[$s3][$s1]=sqrt($val1);
				
				#$val2+=$ed[$s3][$s1];
				$val1=0;
			}
			#@eda[$s3]=$val2;
			$val2=0;
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
			for($s1=0;$s1<$clusd;$s1++){#print "$s1\t";
				for($s2=0;$s2<$clusd;$s2++){#print "$s1\t";
					if($ed[$s3][$s2]!=0){
						$otprnmn[$s3][$s1]=($ed[$s3][$s1]/$ed[$s3][$s2])**(2/($m-1));
						$val1+=$otprnmn[$s3][$s1];
					}
					else{
						#print "$s1\t$s2\t$ed[$s3][$s1]-$ed[$s3][$s2]\n";
						$otprnmn[$s3][$s1]=1;
					}
				}
				if($val1!=0){
					$val1=1/$val1;
				}
				else{
					#print "Val1-$val1\n";
					$val1=1;
				}
				$val2+=$val1;
				$val3=abs($otprn[$s3][$s1]-$val1);
				$val4+=$val3;
				$otprn[$s3][$s1]=$val1;
				print FP"$val1\t";
				$val1=0
			}
			print FP"\n";$val1=0;
		}
		$val5=$val4/(($s1)*$s3);
		close FP;
		return $val5;
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

