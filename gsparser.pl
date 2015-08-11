#!/perl/user/bin/perl
use Bio::SeqIO;
 use Bio::Seq;
open(FILEHANDLE,"base") ||
              die "can't open $name: $!";
while ($line=<FILEHANDLE>) {
    chomp($line);
    if ($line =~ /\.\./)
    {
    push(@table,$line) ;
    }
    #print "$line \n";
}
foreach $a(@table) {
  @b=split(/\.\./,$a);
     push(@start,$b[0]);
     push(@stop,$b[1]);
     #print "$b[0] $b[1] \n";
    # }
    #print "$b[1]+150 \n";
 $in  = Bio::SeqIO->new('-file' => "11953.txt",
                         '-format' =>'Fasta');
 my $seq = $in->next_seq();
 $x = $seq->subseq($b[0]-300,$b[1]+300);
 #print "$x \n";
  print "> SEQUENCE \n";
  print "$x \n";
              # print "$subseq \n\n";
               # $j++;
	#$subseq=""; $newseq="";
  }



