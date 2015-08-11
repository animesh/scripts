#!/usr/bin/perl
use Bio::SeqIO;
#$seq = "";
open(FILEHANDLE,"noncodnegregap1.txt") ||
              die "can't open $name: $!";

while ($line = <FILEHANDLE>){
 chomp($line);
    if ($line =~/\s+/)
    {
    push(@arr,$line) ;
    }
  }
   print "@arr \n";

     foreach $line(@arr) {
  @b=split(/\s+/,$line);
     push(@start,$b[0]);
     push(@stop,$b[1]);
#     print "$b[0] $b[1] \n";
 #    }
 $in  = Bio::SeqIO->new('-file' => "ap1.txt",
                         '-format' =>'Fasta');
 my $seq = $in->next_seq();
 $x = $seq->subseq($b[0],$b[1]);
 #print "$x \n";

  #print "$x \n";
#}
$line1 = reverse ($x);
 print "> SEQUENCE \n";
print "$line1 \n";
}



