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


$fp=$file1_$file2.".comp.txt";
open (FP,">$fp");
$fm=$file1_$file2.".mat.txt";
open (FM,">$fm");

for($c1=0;$c1<=$#seq1;c1++){
    	open(F1,">file1");
    	print F1">$seqname1[$c1]\n$seq1[$c1]\n";
	for($c2=0;$c2<=$#seq2;c2++){		
	    open(F2,">file2");
	    print F2">$seqname2[$c2]\n$seq2[$c2]\n";
	    print "Aligning seq $seqname1[$c1] and seq $seqname2[$c2] with ";
	    system("needle file1 file2 -gapopen=10 -gapext=0.5 -outfile=file3");
	    open(FN,"file3");
            my $length;
	    while(my $line=<FN>){
		if($line=~/^# Length: /){chomp $line;my @t=split(/\:/,$line);$length=@t[1];}
		if($line=~/^# Identity:     /){
		   my @t=split(/\(|\)/,$line);
		   @t[1]=~s/\%|\s+//g;
		   my $per_sim=@t[1]+0;
		   #if($max<$per_sim){
		       $max=$per_sim;
		       $max_seq_name=$i;
		   print FP"$o-$i $seq_o_name\t$seq_i_name\t$per_sim\t$seq_o_length\t$seq_i_length\t$length\n";
		   print FM"$per_sim\t";
		   #}

		}
	    }
	    close FN;
	    close F1;
	    close F2;
	}
	print FM"\n";
}	

sub needle_string_match{
    my $o=shift;
    my $i=shift;
    my $max_seq_name;
    my $max=90;
    my $seq_o=$total_seq{$o};
    my $seq_i=$other_source_sequence{$i};
    $seq_i=~s/\-/N/g;
    $seq_o=~s/\-/N/g;
    my $seq_o_name=$total_seq_name{$o};
    my $seq_i_name=$other_source_sequence_name{$i};
    my $seq_o_length=length($total_seq{$o});
    my $seq_i_length=length($other_source_sequence{$i});

    #return($max,$max_seq_name);

}

