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
$file2=shift @ARGV; 
chomp $file2; 
open F2,$file2; 
$rown=0;$rulc=0;$gene=0;$rule=0; 
$ftr=shift @ARGV; 
$ftrain=shift @ARGV; 
$ftest=shift @ARGV; 
$cluster=2; 
open(FT1,">t1.txt");
open(FT2,">t2.txt");
 
 
	$choose="cen"; 
	$m=shift @ARGV;
	$iter=shift @ARGV; 
	$minval=0.0000001; 
	$sbcont=100; 
	$clusd=2; 
	$eta=0.001; 
	$etan=0.0001; 
	$etas=0.0001; 
	$thresh=0.0000001; 
	$misclasst=0; 
	$mixval=100; 
 
 
push(@lab,1);push(@lab,2); 
RULESUB(); 
TRAINING($ftrain); 
TEST($ftest); 
 
sub RULESUB{ 
	while($l=<F2>){ 
		$rule=0; 
		$rulc=0; 
		$rown++; 
		@t=split(/\s+/,$l);#$len=(@t); 
		if($l=~/^Rule/ and @t[$c]!~/-/){$rules++;} 
			$gene=0; 
			for($c=2;$c<=($ftr*3+1);$c=$c+3){ 
				#print "$c\t@t[$c]\t"; 
				if($l=~/^Rule/ and @t[$c]!~/-/){ 
					if($rulc%1==0){$rule++;} 
					$X1=(@t[$c])*($max{$rule-1}-$min{$rule-1})+$min{$rule-1}; 
					$X2=(@t[$c+2])*($max{$rule-1}-$min{$rule-1}); 
					#print "$rown:$rule:$X1:@t[$c] [$max{$rule-1} - $min{$rule-1}] [$meann{$rule-1}:$mean{$rule-1}]:$X2:@t[$c+2] [$stdn{$rule-1}:$std{$rule-1}]\n"; 
					#print "$rown:$rule:$X1:@t[$c] [$maxoldaml{$rule-1} - $minoldaml{$rule-1}] [$meannewaml{$rule-1}:$meanoldaml{$rule-1}]:$X2:@t[$c+2] [$stdnewaml{$rule-1}:$stdoldaml{$rule-1}]\n"; 
					#print "$rown:$rule:$X1:@t[$c] [$meann{$rule-1}:$mean{$rule-1}]:$X2:@t[$c+2] [$stdn{$rule-1}:$std{$rule-1}]\n"; 
					$X1=(@t[$c]); 
					$X2=(@t[$c+2]); 
					print FT1"$X1\t"; 
					print FT2"$X2\t"; 
					$gene++; 
					#print "$gene\t$rules\t$rown\t$X1\t$X2\n"; 
					if($rules<=$cluster){ 
						$mean[0][($rules-1)%$cluster][$gene-1]=$X1; 
						$stddev[0][($rules-1)%$cluster][$gene-1]=$X2; 
						$trainvalcen[0][($rules-1)%$cluster][$gene-1]=$X1; 
						$trainvalstd[0][($rules-1)%$cluster][$gene-1]=$X2; 
					} 
					else{ 
						$mean[1][($rules-1)%$cluster][$gene-1]=$X1; 
						$stddev[1][($rules-1)%$cluster][$gene-1]=$X2; 
						$trainvalcen[1][($rules-1)%$cluster][$gene-1]=$X1; 
						$trainvalstd[1][($rules-1)%$cluster][$gene-1]=$X2; 
					} 
					#print "MeanOld-$meanold{$c2}\tStdOld-$std{$c2}\t"; 
					$rulc++; 
				} 
 
			} 
		print FT1"\n"; 
		print FT2"\n"; 
	} 
		#print "$rules\t$ftr\n"; 
 
	close F2; 
#	for($c0=0;$c0<$cluster;$c0++){ 
#		for($c1=0;$c1<$cluster;$c1++){ 
#			for($c2=0;$c2<$ftr;$c2++){ 
#				print "$c0-$c1-$c2-$mean[$c0][$c1][$c2]\t$stddev[$c0][$c1][$c2]\t"; 
#				#print "$mean[$c0][$c1][$c2]\t$stddev[$c1][$c2]\t"; 
#			} 
#			print "\n"; 
#		} 
#	} 
} 
 
 
sub TEST{undef %train; 
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
 
#sub TEST{ 
#	$ftest=shift; 
#	if($ftr != "") {$rowtest=0; 
#		open(FTT,$ftest); 
#		while($l1=<FTT>){ 
#			@t1=split(/\s+/,$l1); 
#				for($c2=0;$c2<$ftr;$c2++){ 
#					$mattest[$rowtest][$c2]=@t1[$c2]+0; 
#					} 
#				for($c3=$ftr;$c3<=$#t1;$c3++){ 
#					$otptest[$rowtest][$c3]=@t1[$c3]+0; 
#					if($otptest[$rowtest][$c3]==1){$label=$c3-$ftr;} 
#				} 
#			$test{$rowtest}=$label; 
#			#print "$rowt\t$test{$rowtest}\n"; 
#			$rowtest++;$label=0; 
#		} 
#		close FTT; 
#	} 
#	#$mixval=LEARN($ftest,0); 
#	return $mixval; 
#} 
 
 
sub LEARN{$avgerr=$rowt*$ftr;$literval=0;$misnas=$rowt;$ftlearn=shift;$iter=shift; 
	$ftncen=$ftlearn.".cennew.out"; 
	 
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
