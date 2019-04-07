if( @ARGV ne 2){die "\nUSAGE\t\"ProgName MultSeqFile1 MultSeqFile2\t\n\n\n";}
$thresh=90;
$file1 = shift @ARGV;
open (F, $file1) || die "can't open \"$file1\": $!";
$seq="";
while ($line = <F>) {
	chomp $line;
	if ($line =~ /^>/){
		$c++;
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
	chomp $line;
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


$fp=$file1.$file2.".comp.txt";
open (FP,">$fp");
$fm=$file1.$file2.".mat.txt";
open (FM,">$fm");

for($c1=0;$c1<=$#seq1;$c1++){
    	open(F1,">file1");
    	print F1">$seqname1[$c1]\n$seq1[$c1]\n";
	my $len1=length($seq1[$c1]);
	for($c2=0;$c2<=$#seq2;$c2++){		
	    my $len2=length($seq2[$c2]);
	    open(F2,">file2");
	    print F2">$seqname2[$c2]\n$seq2[$c2]\n";
	    print "Aligning seq $seqname1[$c1] and seq $seqname2[$c2] with ";
	    system("water file1 file2 -outfile=file3 -gapopen 10.0 -gapextend 0.5");
	    open(FN,"file3");
            my $length;
		undef $per_sim;	
	    while($line=<FN>){
		if($line=~/^# Length: /){chomp $line;my @t=split(/\:/,$line);$length=@t[1];}
		if($line=~/^# Identity/){
		   my @t=split(/\(|\)/,$line);
		   @t[1]=~s/\%|\s+//g;
		   $per_sim=@t[1]+0;
		}
	    }
	    close FN;
		   print FP"$seqname1[$c1] and $seqname2[$c2]\t$per_sim\t$length\t$len1\t$len2\n";
		print FM"$per_sim\t";
	    close F1;
	    close F2;
	    #if($per_sim>=$thresh){
		#	print "\n: $per_sim > = $thresh :\n";
		#	   print FM"$c1-$c2-$per_sim\n";
		#	last;
	    #}
	}
        print FM"\n";

}	


