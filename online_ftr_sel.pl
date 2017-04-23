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
#if((@ARGV)!=2){die "USAGE: progname_name feature_file_with_OUTPUT_vector no_of_feature\n";}
$f=shift @ARGV;
$ftr=shift @ARGV;
READDATA();
$m=2;
$threshold=0.0000000001;
#$minval=shift @ARGV;
$sbcont=1000;
$clusd=2;
$features=$ftr;
$samples=$row;
$class=$c3-$ftr;
$iter=1000;
$eta=0.3;
$hlayers=1;
$hidnodez=30;
$pstatus=1;
$gamma=(-5);
for($c1=0;$c1<$hlayers;$c1++){
	@HL[$c1]=$hidnodez;
}

INITIALIZE();

LEARNING();

print "SSE after iteration-$iterno:$squareerror [$invsqerr]\t";
MISCLASSIFICATION();

sub READDATA {
	if($ftr != "") {
		open(F,$f);
		$foo=$f.".out";
		open(FO,">$foo");
		$c1=0;$rowno=0;
		while($l1=<F>){
			@t1=split(/\s+/,$l1);
				for($c2=0;$c2<$ftr;$c2++){
					$data[$c1][$c2]=@t1[$c2]+0;
					}
				for($c3=$ftr;$c3<=$#t1;$c3++){
					$c5=$c3-$ftr;			
					$target[$c1][$c5]=@t1[$c3]+0;
					if(@t1[$c3]==1){$label=$c3-$ftr+1;}
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
}


sub INITIALIZE{
	for($c1=0;$c1<$hlayers;$c1++){
		$hidnodez=@HL[$c1];
		if($c1==0){
			for($c2=0;$c2<$features;$c2++){
				@ofs[$c2]=$gamma;
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

sub LEARNING{$iterno=0;$invsqerr=$class*$samples;
	$fg=$f."ofs.txt";
	open(FG,">$fg");
	while(($iterno < $iter) and ( $invsqerr >= $threshold )){
		$squareerror =0;
		for( $datarow = 0; $datarow < $samples; $datarow++){
			FORWARD($datarow);
			for($c1 = 0; $c1 < $class; $c1++){
			$squareerror+=(@output3[$c1]-$target[$datarow][$c1])**2;
			}
		}
		if($iterno%($pstatus)==0){
		   print "SSE after iteration-$iterno:\t$squareerror [$invsqerr]\t";
			for($i=0; $i<$features; $i++){
				$gatv=1/(1+exp(-(@ofs[$i])));
				print FG"$gatv\t";
				#print FG"@ofs[$i]\t";
			}
			print FG"\n";
		   MISCLASSIFICATION();
		} 

	   for( $datarow = 0; $datarow < $samples; $datarow++){
			FORWARD($datarow);
			for( $k = 0; $k < $hidnodez; $k++){
				@delta2[$k] = 0;
			}
			for( $i = 0; $i < $class; $i++){
			   @error[$i]=@output3[$i]-$target[$datarow][$i];
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
					  $weight12[$i][$j]-=($eta*@delta2[$j]*$data[$datarow][$i]*(1-@output2[$j])*@output2[$j]); 
				}
			}
			for($i=0; $i<$features; $i++){
				for($j=0;$j<$hidnodez;$j++){
					  $errorgamma+=($weight12[$i][$j]*@delta2[$j]); 
				}
				@ofs[$i]-=($eta*$data[$datarow][$i])*(1/(1+exp(-(@ofs[$i]))))*(1-(1/(1+exp(-(@ofs[$i])))))*$errorgamma;
				$errorgamma=0;
			}
		 }
	$iterno++;
	$invsqerr=$squareerror/($samples*$class);
	}
	close FG;
}

sub FORWARD{
$dataNo=shift;
	
	for ($kf = 0; $kf < $hidnodez; $kf++){
	      @output2[$kf] = CALOP1($kf,$dataNo);
	}
	for( $if = 0; $if < $class; $if++){
          @output3[$if] = CALOP2($if);
	}
}

sub CALOP1{
$hiddenUnitID=shift;
$datarow=shift;
$temp1=0;
   for($ic1=0;$ic1<$features;$ic1++){
      $temp1+=$weight12[$ic1][$hiddenUnitID]*$data[$datarow][$ic1]*(1/(1+exp(-(@ofs[$ic1]))));
	  #print "@ofs[$ic1]";
	  #/*atten[n];*/
   }
   $return1 = 1/(1 + exp(-($temp1)));
  return($return1);
}



sub CALOP2{
$classID=shift;$temp2=0;
    for( $kc2 = 0; $kc2 < $hidnodez ; $kc2++){
      $temp2+=$weight23[$classID][$kc2]*@output2[$kc2];
	}
  $return2 = 1/(1 + exp(-$temp2));

  return($return2);
} 


sub MISCLASSIFICATION{
   $misclas=0;	
   for($r1=0; $r1 < $samples; $r1++){
	   FORWARD($r1);
        for($ims=0; $ims< $class; $ims++){
			if($output3[$ims]>$max){ 
				$max = $output3[$ims];
                $label = $ims;
			}
		}
		if($target[$r1][$label]!=1){$misclas++;}
      $max =0; $label =0;
     }

  printf "MISCLASSIFICATION-$misclas\n";
}


TEST();
sub TEST
{  
print "Test filename? - ";
$choice=<>;chomp $choice;
open(FT,$choice);
		while($l1=<FT>){
			@t1=split(/\s+/,$l1);
				for($c2=0;$c2<$ftr;$c2++){
					$data[$c1][$c2]=@t1[$c2]+0;
					}
				for($c3=$ftr;$c3<=$#t1;$c3++){
					$c5=$c3-$ftr;			
					$target[$c1][$c5]=@t1[$c3]+0;
					if(@t1[$c3]==1){$label=$c3-$ftr+1;}
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
   print "Misclassification on test data - \n";
   MISCLASSIFICATION();
}
