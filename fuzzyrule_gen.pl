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
	$ftt=$f;
	#$ftt=shift @ARGV;
	$fttt=shift @ARGV;

	$ftr=shift @ARGV;
	$m=1.15;
	$iter=150;
	$minval=0.0001;
	#$minval=shift @ARGV;
	$sbcont=100;
	$clusd=3;
	$eta=0.001;
	$etan=0.0001;
	$etas=0.0001;
	$thresh=0.0001;
	$misclasst=0;
	$mixval=100;
#while($mixval>0){
MAINPROC();
#}
sub MAINPROC{
	READDATA($f);
	CLUSTERING($f);
	TRAINING($ftt);
	$mixval=TEST($fttt);
}

sub TRAINING{
	$ftrain=shift;
	if($ftr != "") {$rowt=0;
		open(FT,$ftrain);
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
	LEARN($ftrain,$iter);
}

sub TEST{
	$ftest=shift;
	if($ftr != "") {$rowt=0;
		open(FTT,$ftest);
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
	$mixval=LEARN($ftest,0);
	return $mixval;
}

sub LEARN{$avgerr=$rowt*$ftr;$literval=0;$misnas=$rowt;$ftlearn=shift;$iter=shift;
	$ftncen=$ftlearn.".cen.out";
	
	while(($literval<=$iter) and (($avgerr>=$thresh) and ($misnas>$misclasst))){
		open(FTRCEN,">$ftncen");
		$maxerrold=$maxerr;$maxerr=0;$misnasold=$misnas;$misnas=0;
		$ftres=$ftlearn.".test.out";
		open(FTR,">$ftres");
		$ftnull=$ftlearn.".null.out";
		open(FTRN,">$ftnull");
		print FTR"Data\#\tRealClass-SubClus\tMisClass-Subclus\n";
		for($a0=0;$a0<$rowt;$a0++){
			$maxa=0;$maxna=0;$maxacol=0;$maxnacol=0;
			for($a1=0;$a1<=$#lab;$a1++){
				for($a2=0;$a2<$clusd;$a2++){
					$firingst=1;
					print FTRN"$a0\t$a1\t$a2\t";
					for($a3=0;$a3<$ftr;$a3++){$firingstold=$firingst;
							if($trainvalstd[$a1][$a2][$a3]!=""){
								$fstre=(1/exp((($mattrain[$a0][$a3]-$trainvalcen[$a1][$a2][$a3])**2)/($trainvalstd[$a1][$a2][$a3]**2)));
								#if($fstre>0.9){
									$firingst*=$fstre;
								#}
								#print FTRN"$a3-$firingst\t";
							}
							else{
								#print FTRN"$a3-$trainvalstd[$a1][$a2][$a3]\t";
								#$firingst=$firingstold;
							}
					}
					print FTRN"\n";
					if($train{$a0}==$a1 and $firingst>=$maxa and $firingst!=1){
						
						$maxa=$firingst;$maxacol="$a1-$a2";
						#print FTRN"FORMAX-$a1\t$a2\t$maxa\t$maxna\t$firingst\n";
					}
					elsif($train{$a0}!=$a1 and $firingst>=$maxna and $firingst!=1){
						$maxna=$firingst;$maxnacol="$a1-$a2";
						#print FTRN"FORMAXNA-$a1\t$a2\t$maxa\t$maxna\t$firingst\n";
					}
					#else{print FTRN"ELSE-$a1\t$a2\t$maxa\t$maxna\t$firingst\n";}
				}
				for($a2=0;$a2<$clusd;$a2++){
					for($a3=0;$a3<$ftr;$a3++){
						#print FTRCEN"$trainvalcen[$a1][$a2][$a3] $trainvalstd[$a1][$a2][$a3]\t";
						if(($train{$a0}==$a1) and  $trainvalstd[$a1][$a2][$a3]){
							$trainvalcen[$a1][$a2][$a3]+=$etan*(1-$maxa+$maxna)*($maxa/($trainvalstd[$a1][$a2][$a3]**2))*($mattrain[$a0][$a3]-$trainvalcen[$a1][$a2][$a3]);
							$trainvalstd[$a1][$a2][$a3]+=$etas*(1-$maxa+$maxna)*($maxa/($trainvalstd[$a1][$a2][$a3]**3))*(($mattrain[$a0][$a3]-$trainvalcen[$a1][$a2][$a3])**2);
						}
						elsif($trainvalstd[$a1][$a2][$a3]){
							$trainvalcen[$a1][$a2][$a3]-=$etan*(1-$maxa+$maxna)*($maxna/($trainvalstd[$a1][$a2][$a3]**2))*($mattrain[$a0][$a3]-$trainvalcen[$a1][$a2][$a3]);
							$trainvalstd[$a1][$a2][$a3]-=$etas*(1-$maxa+$maxna)*($maxna/($trainvalstd[$a1][$a2][$a3]**3))*(($mattrain[$a0][$a3]-$trainvalcen[$a1][$a2][$a3])**2);
						}
						#print FTRCEN"$trainvalcen[$a1][$a2][$a3] $trainvalstd[$a1][$a2][$a3]\t";
					}
					#print "$ct[$a0][$a1][$a2]\n";
					#print FCC"$a1\t$a2\t$maxa-$maxna\t";
				}
				#print FTRCEN"\n";

			}
			#if(($exist{"$a1-$a2"}!=1) and ($exist{"$a1-$a2"}!=0)){
				if(($maxa<$maxna)){$misnas++;$missam{$maxacol}++;}
				else{$trusam{$maxacol}++;};
				#print FCC"$a0\t$maxa-$maxna\t$misnas\t$maxerr\n";
				$maxerr+=((1-$maxa+$maxna)**2);
			#}
			$totalsam{$train{$a0}}++;
			$cnta{$maxacol}++;
			$cntp{$maxnacol}++;
			print FTR"$a0\t$maxacol [$maxa]\t\t\t$maxnacol [$maxna]\t\t";
			if(($maxa<$maxna)){print FTR"Misclassified [Actual-$maxacol\tPredicted-$maxnacol]\t$misnas\n";}
			else{print FTR"\n";}
		}
		
		$avgerr=$maxerr/($rowt*$ftr);
		print "$literval\t$avgerr\t$misnas\n";
			open(FWRITE,">t1.txt");
			print FWRITE"$literval\t$avgerr\t$misnas\n";
			close FWRITE;

		if(($misnasold<$misnas) or ($maxerrold<$maxerr)){
			$etas=(1-$eta)*$etas;
			$etan=(1-$eta)*$etan;
		}
		for($a1=0;$a1<=$#lab;$a1++){
			for($a2=0;$a2<$clusd;$a2++){$cf++;
				print FTRCEN"Rule:$cf [$a1-$a2]\t";
				for($a3=0;$a3<$ftr;$a3++){
					$meanp=substr($trainvalcen[$a1][$a2][$a3],0,6);
					$stdp=substr($trainvalstd[$a1][$a2][$a3],0,6);
					print FTRCEN"$meanp - $stdp\t\t";
				}
				print FTRCEN"$totalsam{$a1} [$trusam{\"$a1-$a2\"}-$missam{\"$a1-$a2\"}] \t$cnta{\"$a1-$a2\"}\t$cntp{\"$a1-$a2\"}\n";
			}
		}
		$cf=0;
		print FTRCEN"$literval\t$misnas\n";
		$literval++;
		close FTR;close FTRN,
		undef %cnta;undef %cntp;undef %totalsam;undef %missam;undef %trusam;
	}
		close FTRCEN;
		return $misnas;
}



sub READDATA{
	$fread=shift;
	if($ftr != "") {
		open(F,$fread);
		#$foo=$f.".out";
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
	$fclust=shift;
	$foc=$fclust.".clust.txt";
	open(FCC,">$foc");
	$foco=$fclust.".clustnull.txt";
	open(FCCNULL,">$foco");

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
				for($s2=0;$s2<$ftr;$s2++){$meanval=0;$N=0;
					for($s1=0;$s1<$c1;$s1++){
						if($_ ==$maxcolsam{$s1}){
							$meanval+=$mat[$s1][$s2];$N++;
						}
					}
				$meanval{$s2}=$meanval/$N;
				
				}
				$exists="";
				print FCC"$a1\t$_\t";
				print FCCNULL"$a1\t$_\t";
				for($s2=0;$s2<$ftr;$s2++){$stddevval=0;$N=0;$stddevvalsb=0;
					for($s1=0;$s1<$c1;$s1++){
						if($_ ==$maxcolsam{$s1}){
							$stddevval+=($mat[$s1][$s2]-$meanval{$s2})**2;$N++;
							$stddevvalsb+=($mat[$s1][$s2]-$otprnm[$s2][$_])**2;
						}
					}
					#$stddevval{$s2}=sqrt($stddevval)/$N;
					$stddevvalsb{$s2}=sqrt($stddevvalsb)/$N;
					#print "$meanval{$s2}\t";#$otprnm[$s2][$_]\t$stddevval{$s2}\t$stddevvalsb{$s2}\t";#$stddevval{$s2}\t
					$trainvalmean[$a1][$_][$s2]=$meanval{$s2};
					$trainvalstd[$a1][$_][$s2]=sqrt($stddevval)/$N;
					$trainvalcen[$a1][$_][$s2]=$otprnm[$s2][$_];
					$trainvalstdcen[$a1][$_][$s2]=$stddevvalsb{$s2};
					$exists+=$trainvalstd[$a1][$_][$s2];
					
					if($trainvalstd[$a1][$_][$s2]!=""){print FCC"$s2-$trainvalstd[$a1][$_][$s2]\t";}
					else{print FCCNULL"$s2-$trainvalstd[$a1][$_][$s2]\t";}
				}
				print FCC"\n";
				print FCCNULL"\n";
				$exist{"$a1-$_"}=$exists;
				#print FCC"$a1\t$_\t$maxcolhash{$_}\t$exist{\"$a1-$_\"}\n";
				print "$a1\t$_\t$maxcolhash{$_}\t$exist{\"$a1-$_\"}\n";
			}
			undef %maxcolhash;undef %maxcolsam;
			undef %stddevvalsb;undef %stddevval;
			undef %meanval;#undef %stddevval;

	}
	close FCC;close FCCNULL;
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

