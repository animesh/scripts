$min=Inf;
$max=-Inf;
while(<>){
chomp;
@tmp=split(/\s+/);
@name=split(/\-/,@tmp[1]);
push(@nam1,@name[0]);
push(@nam2,@name[1]);
$heat{"@tmp[1]"}=@tmp[2];
if(@tmp[2]>$max){$max=@tmp[2]};
if(@tmp[2]<$min){$min=@tmp[2]};
}
%seen = (); @name1 = grep { ! $seen{ $_ }++ } @nam1;
%seen = (); @name2 = grep { ! $seen{ $_ }++ } @nam2;
for($c1=0;$c1<=$#name1;$c1++){
	$n1 = @name1[$c1] ;
	#$n1 =~ s/scf7180001/C/g;
	if($c1==0){
		print "Name, ";
		for($c4=0;$c4<$#name2;$c4++){
			$n2=@name2[$c4];
			#$n2=~s/scaffold/N/g;
			print "$n2, ";
		}
               $n2=@name2[$c4];
         #      $n2=~s/scaffold/N/g;
 		print "$n2\n";
	}
	print "$n1, ";
	for($c2=0;$c2<$#name2;$c2++){
		$valz=$heat{"@name1[$c1]-@name2[$c2]"};
		$vnorm=($valz-$min)/($max-$min);
		print "$valz, ",
		#print "$vnorm, ",
		#if($valz){print "$valz,";}
		#else{print "0,";}
	}
	$valz=$heat{"@name1[$c1]-@name2[$c2]"};
	$vnorm=($valz-$min)/($max-$min);
	print "$valz\n",
	#print "$vnorm\n",
	#if($valz){print "$valz\n";}
	#else{print "0\n";}
	
}

