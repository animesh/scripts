#!/usr/bin/perl

$file = shift @ARGV;
open(F,$file)||die "no such file";

%t2o = (
      'ALA' => 'A',
      'VAL' => 'V',
      'LEU' => 'L',
      'ILE' => 'I',
      'PRO' => 'P',
      'TRP' => 'W',
      'PHE' => 'F',
      'MET' => 'M',
      'GLY' => 'G',
      'SER' => 'S',
      'THR' => 'T',
      'TYR' => 'Y',
      'CYS' => 'C',
      'ASN' => 'N',
      'GLN' => 'Q',
      'LYS' => 'K',
      'ARG' => 'R',
      'HIS' => 'H',
      'ASP' => 'D',
      'GLU' => 'E',
);


while($l=<F>){
	$s="";
	if($l=~/^SEQRES/){
		@t=split(//,$l);
		for($c1=19;$c1<=67;$c1=$c1+4) {
		$cs{@t[11]}.=$t2o{@t[$c1].@t[$c1+1].@t[$c1+2]};
		$s.=$t2o{@t[$c1]};
		}
	}
	$seq.=$s;$s="";
	if($l=~/^HELIX/){
		@t=split(//,$l);
		$str=@t[21].@t[22].@t[23].@t[24]+0;
		$stp=@t[33].@t[34].@t[35].@t[36]+0;
		$s=substr($cs{@t[19]},($str-1),($stp-$str+1));
		@t2=split(//,$s);
			for($c2=0;$c2<=$#t2;$c2++){
				$s1=@t2[$c2]."-".@t[19]."-".($str+$c2);$s2="H";
				$aap{$s1}=$s2;
				#print "$str\t$stp\t$s1=>$aap{$s1}\n";
			}
		}
	@t2=split(//,$s);
	for($c2=0;$c2<=$#t2;$c2++){
		for($c3=($c2+1);$c3<=$#t2;$c3++){
			$tag=@t2[$c2].'-'.@t2[$c3];
			$helix{$tag}.="-".($c3-$c2);
			$rtag=reverse($tag);
			$helix{$rtag}.="-".($c3-$c2);
		}
	}
	$s="";

	if($l=~/^SHEET/){
		@t=split(//,$l);
		$str=@t[22].@t[23].@t[24].@t[25]+0;
		$stp=@t[33].@t[34].@t[35].@t[36]+0;
		$s=substr($cs{@t[21]},($str-1),($stp-$str+1));
		@t2=split(//,$s);
			for($c2=0;$c2<=$#t2;$c2++){
				$s1=@t2[$c2]."-".@t[21]."-".($str+$c2);$s2="S";
				$aap{$s1}=$s2;
				#print "$str\t$stp\t$s1=>$aap{$s1}\n";
			}
		}
	@t2=split(//,$s);
	for($c2=0;$c2<=$#t2;$c2++){
		for($c3=($c2+1);$c3<=$#t2;$c3++){
			$tag=@t2[$c2].'-'.@t2[$c3];
			$sheet{$tag}.="-".($c3-$c2);
			$rtag=reverse($tag);
			$sheet{$rtag}.="-".($c3-$c2);

		}
	}
	$s="";

	if($l=~/^TURN/){
		@t=split(//,$l);
		$str=@t[20].@t[21].@t[22].@t[23]+0;
		$stp=@t[31].@t[32].@t[33].@t[34]+0;
		$s=substr($cs{@t[19]},($str-1),($stp-$str+1));
		@t2=split(//,$s);
			for($c2=0;$c2<=$#t2;$c2++){
				$s1=@t2[$c2]."-".@t[19]."-".($str+$c2);$s2="T";
				$aap{$s1}=$s2;
				#print "$str\t$stp\t$s1=>$aap{$s1}\n";
			}
		}
	@t2=split(//,$s);
	for($c2=0;$c2<=$#t2;$c2++){
		for($c3=($c2+1);$c3<=$#t2;$c3++){
			$tag=@t2[$c2].'-'.@t2[$c3];
			$turn{$tag}.="-".($c3-$c2);
			$rtag=reverse($tag);
			$turn{$rtag}.="-".($c3-$c2);
		}
	}
	if($l=~/^ATOM/){
		@t=split(//,$l);
		$nm=@t[0].@t[1].@t[2].@t[3];$rn=@t[12].@t[13].@t[14].@t[15];
		if($nm=~/ATOM/ and $rn=~/CA/){#$c9++;
			$pos=@t[22].@t[23].@t[24].@t[25]+0;
			$s1=$t2o{@t[17].@t[18].@t[19]}."-".@t[21]."-".$pos;
			$x=@t[30].@t[31].@t[32].@t[33].@t[34].@t[35].@t[36].@t[37]+0;
			$y=@t[38].@t[39].@t[40].@t[41].@t[42].@t[43].@t[44].@t[45]+0;
			$z=@t[46].@t[47].@t[48].@t[49].@t[50].@t[51].@t[52].@t[53]+0;
			$s2=$x.":".$y.":".$z;
			$aac{$s1}=$s2;
			#print "$c9\t$s1=>$aac{$s1}=>$aap{$s1}\n";
		}
	}
}
close F;
##$l=length($seq);print "$l\n$seq\n";$c=0;
#$c=0;print "HELIX\n";
#foreach (keys %helix){$c++;
#	print "$c\t$_ => $helix{$_}\n";
#}
#
#$c=0;print "SHEET\n";
#foreach (keys %sheet){$c++;
#	print "$c\t$_\t$sheet{$_}\n";
#}
#
#$c=0;print "TURN\n";
#foreach (keys %turn){$c++;
#	print "$c\t$_\t$turn{$_}\n";
#	}
#
#$c1=0;$c2=0;
#foreach $w1 (keys %helix){$c1++;$c2=0;
#	foreach $w2 (keys %sheet){$c2++;
#		if($w1 eq $w2){
#		$val=SNR($helix{$w1},$sheet{$w2});
#		$key="$w1\t$helix{$w1}\t$sheet{$w2}";
#		$sum{$key}=$val;
##		print "$w1\t$\"c1:$c2\"\t\"$helix{$w1}:$sheet{$w2}\"\t$val\n";
#		}
#	}
#}
$c1=0;$c2=0;
foreach $w1 (keys %aac){$c1++;$c2=0;
	foreach $w2 (keys %aac){$c2++;
		if($w1 ne $w2){
		$val=ED($aac{$w1},$aac{$w2});
		$key="$w1-$w2-$aap{$w1}-$aap{$w2}";
		$sum{$key}=$val;
		#print "$w1:$w2\t\"$aac{$w1}:$aac{$w2}\"\t$val \"$aap{$w1}:$aap{$w2}\"\n";
		}
	}
}

foreach $q (sort {$sum{$a} <=> $sum{$b}} keys %sum){
	$t=$q;#$len=length($sum{$q});
	@t1=split(/-/,$t);
	$s1=$cs{@t1[1]};@t2=split(//,$s1);
	$p0=@t2[@t1[2]-1]."-".@t1[1]."-".(@t1[2]);
	$p1=@t2[@t1[2]-2]."-".@t1[1]."-".(@t1[2]-1);
	$p2=@t2[@t1[2]]."-".@t1[1]."-".(@t1[2]+1);
	$s1=$cs{@t1[4]};@t2=split(//,$s1);
	$p3=@t2[@t1[5]-2]."-".@t1[4]."-".(@t1[5]-1);
	$p4=@t2[@t1[5]]."-".@t1[4]."-".(@t1[5]+1);
	$p5=@t2[@t1[5]-1]."-".@t1[4]."-".(@t1[5]);
	$key="$p0-$p5-$aap{$p0}-$aap{$p5}";
	$key1="$p0-$p1-$aap{$p0}-$aap{$p1}";
	$key2="$p0-$p2-$aap{$p0}-$aap{$p2}";
	$key3="$p5-$p3-$aap{$p5}-$aap{$p3}";
	$key4="$p5-$p4-$aap{$p5}-$aap{$p4}";
	if(@t1[2] ne (@t1[5]-1) and @t1[2] ne (@t1[5]+1) ){
		if($sum{$key}<$sum{$key1} or $sum{$key}<$sum{$key2}){
			print "1-$q\t$key\t$key1\t$key2\t$sum{$key}\t$sum{$key1}\t$sum{$key2}\n";
			}
		if($sum{$key}<$sum{$key3} or $sum{$key}<$sum{$key4}){
			print "2-$q\t$key\t$key3\t$key4\t$sum{$key}\t$sum{$key3}\t$sum{$key4}\n";
			}
	}
	#for  ($c1=0;$c1<=$#t1;$c1++) {print "$c1\t@t1[$c1]\n";}
	#print "@t1\t$sum{$q}\n";
}

sub ED{
	$val1=shift;
	$val2=shift;
	
	@t1=split(/\:/,$val1);
	@t2=split(/\:/,$val2);

	$dis=sqrt((@t1[0]-@t2[0])**2+(@t1[1]-@t2[1])**2+(@t1[2]-@t2[2])**2);
	return $dis;
}

sub SNR{
	$val1=shift;
	$val2=shift;
	
	@t1=split(/\-/,$val1);
	$length=@t1;$N=$length-1;#print "$N\n";
	for($c2=1;$c2<=$#t1;$c2++){
		$temp3+=@t1[$c2];
	}
	$temp3=$temp3/$N;
	for($c2=1;$c2<=$#t1;$c2++){
		$temp5+=($temp3-@t1[$c2])**2;
	}
	$temp5=sqrt($temp5/$N);

	@t1=split(/\-/,$val2);
	$length=@t1;$N=$length-1;#print "$N\n";
	for($c2=1;$c2<=$#t1;$c2++){
		$temp2+=@t1[$c2];
	}
	$temp2=$temp2/$N;
	for($c2=1;$c2<=$#t1;$c2++){
		$temp4+=($temp2-@t1[$c2])**2;
	}
	$temp4=sqrt($temp4/$N);

	if($temp4 eq $temp5){$temp1=1;}
	else{
		$temp1=abs(($temp2-$temp3)/($temp4+$temp5));
		}
	$temp2=0;$temp3=0;$temp4=0;$temp5=0;$temp6=0;$temp7=0;
	return $temp1;
}