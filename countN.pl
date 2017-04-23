if( @ARGV ne 2){die "\nUSAGE\t\"ProgName MultSeqFile1 MultSeqFile2\t\n\n\n";}
$file1 = shift @ARGV;
open (F, $file1) || die "can't open \"$file1\": $!";
$seq="";
while ($line = <F>) {
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		push(@seqname1,$line);	
		if ($seq ne ""){
			push(@seq1,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seq1,$seq);
close F;

$file2 = shift @ARGV;
open (F, $file2) || die "can't open \"$file2\": $!";
$seq="";
while ($line = <F>) {
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		push(@seqname2,$line);	
		if ($seq ne ""){
			push(@seq2,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seq2,$seq);
close F;



for($c1=0;$c1<=$#seq1;$c1++){
	for($c2=0;$c2<=$#seq2;$c2++){		
	if($c1==$c2){
	    $c3=$seq1[$c1]=~s/n/n/g;
	    $c4=$seq2[$c2]=~s/n/n/g;

	    print "$seqname1[$c1]\t$c3\t$seqname2[$c2]\t$c4\n";
	}
	}
}	

