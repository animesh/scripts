#!/usr/bin/perl

#parameters, parameters n, m, η α, an limit on E and maximum number of epochs

#the window size
$n=5;
#hidden node size
$m=3;
#output
$o=3;
#slide of the window
$slide=1;
#number of iteration, maximum number of epochs
$iter=100;
#threshold, an limit on E 
$threshold=0.00000000001;
#learning rate,  η
$eta=0.1;
#momentum,α 
$alpha=0.9;
#hidden layer construct
$hlayers=1;
$hidnodez=$m;
$pstatus=1;
for($c1=0;$c1<$hlayers;$c1++){
	@HL[$c1]=$hidnodez;
}




#Making hashmap for normalized Hydrophobicity
@aa=qw/A    R    N    D    C    Q    E    G    H    I    L    K    M    F    P    S    T    W    Y    V/;
@hval=qw/1.8 -4.5 -3.5 -3.5  2.5 -3.5 -3.5 -0.4 -3.2  4.5  3.8 -3.9  1.9  2.8 -1.6 -0.8 -0.7 -0.9 -1.3  4.2/;
for($c=0;$c<=$#aa;$c++){
	$hvalaa{@aa[$c]}=((@hval[$c]+4.5)/(4.5+4.5));
}

#Making Data hashmap
$TRAINING_DATA{"1auz - P10727"}= "MSLGIDMNVKESVLCIRLTGELDHHTAETLKQKVTQSLEKDDIRHIVLNLEDLSFMDSSGLGVILGRYKQIKQIGGEMVVCAISPAVKRLFDMSGLFKIIRFEQSEQQALLTLGVAS";
$TRAINING_DATA_P{"1auz - P10727"}="   eeeeeee  eeeeeee      hhhhhhhhhhhhh      eeeee        hhhhhhhhhhhh       eeeee      hhhhhhh           hhhhhhh     ";
$TRAINING_DATA{"6tim - P04789"}= "MSKPQPIAAANWKCNGSQQSLSELIDLFNSTSINHDVQCVVASTFVHLAMTKERLSHPKFVIAAQNAIAKSGAFTGEVSLPILKDFGVNWIVLGHSERRAYYGETNEIVADKVAAAVASGFMVIACIGETLQERESGRTAVVVLTQIAAIAKKLKKADWAKVVIAYEPVWAIGTGKVATPQQAQEAHALIRSWVSSKIGADVAGELRILYGGSVNGKNARTLYQQRDVNGFLVGGASLKP";
$TRAINING_DATA_P{"6tim - P04789"}="      eeeee      hhhhhhhhhhhh        eeeee  hhhhhhhhhh     eeeeee  eee         hhhhhh    eeeee hhhhhh    hhhhhhhhhhhhhh  eeeeee   hhhhh    hhhhhhhhhhhhh   hhhhhheeeeee  hhh       hhhhhhhhhhhhhhhhhh  hhhhhh  eeeeee     hhhhh      eeeeehhhh  ";

$VALIDATION_DATA{"2acy - P41500"}=  "MSMAEGDTLISVDYEIFGKVQGVFFRKYTQAEGKKLGLVGWVQNTDQGTVQGQLQGPASKVRHMQEWLETKGSPKSHIDRASFHNEKVIVKLDYTDFQIVK";
$VALIDATION_DATA_P{"2acy - P41500"}="        eeeeeeeeeee eeeehhhhhhhhhhh   eeeeee     eeeeeeeehhhhhhhhhhhhh      eeeeeeeeeeee      eeeeee ";
$VALIDATION_DATA{"3grs - P00390"}=  "MALLPRALSAGAGPSWRRAARAFRGFLLLLPEPAALTRALSRAMACRQEPQPQGPPPAAGAVASYDYLVIGGGSGGLASARRAAELGARAAVVESHKLGGTCVNVGCVPKKVMWNTAVHSEFMHDHADYGFPSCEGKFNWRVIKEKRDAYVSRLNAIYQNNLTKSHIEIIRGHAAFTSDPKPTIEVSGKKYTAPHILIATGGMPSTPHESQIPGASLGITSDGFFQLEELPGRSVIVGAGYIAVEMAGILSALGSKTSLMIRHDKVLRSFDSMISTNCTEELENAGVEVLKFSQVKEVKKTLSGLEVSMVTAVPGRLPVMTMIPDVDCLLWAIGRVPNTKDLSLNKLGIQTDDKGHIIVDEFQNTNVKGIYAVGDVCGKALLTPVAIAAGRKLAHRLFEYKEDSKLDYNNIPTVVFSHPPIGTVGLTEDEAIHKYGIENVKTYSTSFTPMYHAVTKRKTKCVMKMVCANKEEKVVGIHMQGLGCDEMLQGFAVAVKMGATKADFDNTVAIHPTSSEELVTLR";
$VALIDATION_DATA_P{"3grs - P00390"}="                                                                 eeeee   hhhhhhhhhhhh    eeeeeee   hhhhh  hhhhhhhhhhhhhhhhhhh hhh          hhhhhhhhhhhhhhhhhhhhhhhhh   eeeee          eeee  eeee   eee   eee          hhh   hhhh       hhhhhh   hhhhhhhhhhhhh  eeeee eeeee     hhhhhhhhhhhhh   eee  eeeeeeeee  eeeeeeee       eeeeeeeeeeeee   eeee     hhh                       eee hhhh     hhhhhhhhhhhhhhhh              eee     eeeee  hhhhhhhh hhheeeeeeee  hhhhh      eeeeeeee    eeeeeeeee  hhhhhhhhhhhhh    hhhhh          hhhhh  ";


#write training to file with output
open(FTR,">training");
foreach $test (keys %TRAINING_DATA) {
	@temp1=split(//,$TRAINING_DATA{$test});
        @temp2=split(//,$TRAINING_DATA_P{$test});
	for($c=0;$c<=($#temp1-$n);$c+=$slide){
	        for($c2=$c;$c2<($n+$c);$c2++){
			print FTR"$hvalaa{@temp1[$c2]}\t";
		}
                 if(lc(@temp2[($c+$n-1)/2]) eq "e" or lc(@temp2[($c+$n-1)/2]) eq "s"){
                         print FTR"0.1\t0.9\t0.1\n";
                 }

                 if(lc(@temp2[($c+$n-1)/2]) eq "c" or lc(@temp2[($c+$n-1)/2]) eq "u"){
                         print FTR"0.1\t0.1\t0.9\n";
                 }

                 if(lc(@temp2[($c+$n-1)/2]) eq "h"){
                         print FTR"0.9\t0.1\t0.1\n";
                 }
                 else{ 
			print FTR"0.1\t0.1\t0.9\n";
                 }

	}
	print "$test=>$TRAINING_DATA{$test}\n";
}

#write validation data to file with output
open(FTV,">validation");
foreach $test (keys %VALIDATION_DATA) {
	@temp1=split(//,$VALIDATION_DATA{$test});
        @temp2=split(//,$VALIDATION_DATA_P{$test});
	for($c=0;$c<=($#temp1-$n);$c+=$slide){
	        for($c2=$c;$c2<($n+$c);$c2++){
			print FTV"$hvalaa{@temp1[$c2]}\t";
		}
                 if(lc(@temp2[($c+$n-1)/2]) eq "e" or lc(@temp2[($c+$n-1)/2]) eq "s"){
                         print FTV"0.1\t0.9\t0.1\n";
                 }

                 if(lc(@temp2[($c+$n-1)/2]) eq "c" or lc(@temp2[($c+$n-1)/2]) eq "u"){
                         print FTV"0.1\t0.1\t0.9\n";
                 }

                 if(lc(@temp2[($c+$n-1)/2]) eq "h"){
                         print FTV"0.9\t0.1\t0.1\n";
                 }
                 else{ 
			print FTV"0.1\t0.1\t0.9\n";
                 }

	}
	print "$test=>$VALIDATION_DATA{$test}\n";
}

$f="training";
$ftr=$n;
$features=$ftr;
$c3=READDATA();
$samples=$row;
$class=$o;



INITIALIZE();

LEARNING();

print "SSE after iteration-$iterno:$squareerror [$invsqerr]\t";
MISCLASSIFICATION();

#read the input data
sub READDATA {
	if($ftr != "") {
		open(F,$f);
		$foo=$f.".out";
		open(FO,">$foo");
		$c1=0;$rowno=0;
		while($l1=<F>){
			chomp $l1;
			@t1=split(/\t/,$l1);
				for($c2=0;$c2<$ftr;$c2++){
					$data[$c1][$c2]=@t1[$c2]+0;
					}
				for($c3=$ftr;$c3<=$#t1;$c3++){
					$c5=$c3-$ftr;			
					$target[$c1][$c5]=@t1[$c3]+0;
					if(@t1[$c3]==0.9){
						$label=$c3-$ftr+1;
					}
					print FO"$target[$c1][$c5]\t";
				}
					print FO"\n";
			$row=$c1+1;
			$labhash{$row}=$label;
			$clsno{$label}++;
			push(@lab,$label);
			$c1++;$label=0;
		}
		close F;
		close FO;
	}
	else{die "Number of Feature ($ftr) is vague";}
	return $c3;
}

#initialise the network
sub INITIALIZE{
	for($c1=0;$c1<$hlayers;$c1++){
		$hidnodez=@HL[$c1];
		if($c1==0){
			for($c2=0;$c2<$features;$c2++){
				for($c3=0;$c3<$hidnodez;$c3++){
					$weight12[$c2][$c3] = (rand(1)-0.5);#$t++;
					#print "$t\t$weight12[$c2][$c3]\t";
				}
			}
		}
		if(($hlayers-$c1)==1){
			for($c2=0;$c2<$class;$c2++){
				for($c3=0;$c3<$hidnodez;$c3++){
					$weight23[$c2][$c3] = (rand(1)-0.5);#$t++;
					#print "$t\t$weight12[$c2][$c3]\t";
				}
			}
		}		
	}
}

#perceptron 
sub LEARNING{$iterno=0;$invsqerr=$class*$samples;
	while(($iterno < $iter) and ( $invsqerr > $threshold )){
		$squareerror =0;
		for( $datarow = 0; $datarow < $samples; $datarow++){
			FORWARD($datarow);
			for($c1 = 0; $c1 < $class; $c1++){
			$squareerror+=(@output3[$c1]-$target[$datarow][$c1])**2;
			}
		}
		if($iterno%($pstatus)==0){
		   $iterationo=$iterno+1;	
		   print "SSE after iteration - $iterationo:\t$squareerror [$invsqerr]\t";
		   MISCLASSIFICATION();
		} 

	   for( $datarow = 0; $datarow < $samples; $datarow++){
			FORWARD($datarow);
			for( $k = 0; $k < $hidnodez; $k++){
				@delta2[$k] = 0;
			}
			for( $i = 0; $i < $class; $i++){
			   @error[$i]=@output3[$i]-$target[$datarow][$i];
			   #@error[$i]=(@output3[$i]-$target[$datarow][$i])/$target[$datarow][$i];
			}
			for( $i = 0; $i < $class; $i++){
				for( $k = 0; $k < $hidnodez; $k++){
					$weight23[$i][$k]-=($eta*@error[$i]*@output2[$k]*@output3[$i]*(1-@output3[$i]));
				}
			}
			for($k = 0; $k < $hidnodez; $k++){
				for( $i = 0; $i < $class; $i++){ 
						  @delta2[$k]+=(@error[$i]*$weight23[$i][$k]*@output3[$i]*(1-@output3[$i]));
				}
			}

			for($i=0; $i<$features; $i++){
				for($j=0;$j<$hidnodez;$j++){
					  $weight12[$i][$j]-=($alpha*$eta*@delta2[$j]*$data[$datarow][$i]*(1-@output2[$j])*@output2[$j]); 
				}
			}
		 }
	$iterno++;
	$invsqerr=$squareerror/($samples*$class);
	}
}

#feed forward
sub FORWARD{
$dataNo=shift;
	for ($kf = 0; $kf < $hidnodez; $kf++){
	      @output2[$kf] = CALOP1($kf,$dataNo);
	}
	for( $if = 0; $if < $class; $if++){
          @output3[$if] = CALOP2($if);
	}
}

#weight from input to hidden
sub CALOP1{
$hiddenUnitID=shift;
$datarow=shift;
$temp1=0;
   for($ic1=0;$ic1<$features;$ic1++){
      $temp1+=$weight12[$ic1][$hiddenUnitID]*$data[$datarow][$ic1];#/*atten[n];*/
   }
   $return1 = 1/(1 + exp(-($temp1)));
  return($return1);
}


#weight from hidden to output
sub CALOP2{
$classID=shift;$temp2=0;
    for( $kc2 = 0; $kc2 < $hidnodez ; $kc2++){
      $temp2+=$weight23[$classID][$kc2]*@output2[$kc2];
	}
  $return2 = 1/(1 + exp(-$temp2));

  return($return2);
} 

#calculate misclassification
sub MISCLASSIFICATION{
	$file=shift;
	if($file != ""){$f=$file;}
   $filemisclass=$f.".mis.out";
   open(FM,">$filemisclass");
   $misclas=0;	
   for($r1=0; $r1 < $samples; $r1++){
	   FORWARD($r1);
        for($ims=0; $ims< $class; $ims++){
			print FM"$output3[$ims]\t";
			if($output3[$ims]>$max){ 
				$max = $output3[$ims];
                $label = $ims;
			}
		}
		print FM"\n";
		if($target[$r1][$label]!=0.9){$misclas++;}
      $max =0; $label =0;
     }
  printf "MISCLASSIFICATION-$misclas\n";
  close FM;	
}

#test the validation set
TEST("validation");
sub TEST
{  
print "Testing validation data...";
$f=shift;
$choice=$f;
$fileout=$f.".out";
open(FO,">$fileout");
open(FT,$choice);
		while($l1=<FT>){
			@t1=split(/\t/,$l1);
				for($c2=0;$c2<$ftr;$c2++){
					$data[$c1][$c2]=@t1[$c2]+0;
					}
				for($c3=$ftr;$c3<=$#t1;$c3++){
					$c5=$c3-$ftr;			
					$target[$c1][$c5]=@t1[$c3]+0;
					if(@t1[$c3]==0.9){$label=$c3-$ftr+1;}
					print FO"$target[$c1][$c5]\t";
				}
					print FO"\n";
			$row=$c1+1;
			$labhash{$row}=$label;
			$clsno{$label}++;
			push(@lab,$label);
			$c1++;$label=0;
		}
		close FT;
		$samples=$row;
   print "Misclassification on test data $f- \n";
   MISCLASSIFICATION($f);
}

