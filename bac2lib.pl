#!/usr/bin/perl
#>codbac29j5-2o21.rp2_b1.SCF    883      0    883  SCF
#>codbac181n17-1a01.rp2_b1.SCF1  template=codbac181n171a01       dir=R   library=codbac181n17
$file = shift @ARGV;

open(F2,$file);
        
while ($line = <F2>) {

                if ($line =~ /^>/){
                	chomp ($line);
                        $snames=$line;
                        chomp $snames;

                     push(@seqname,$snames);
                        if ($seq ne ""){
                      push(@seq,$seq);

                      $seq = "";
                    }
              } else {$seq=$seq.$line;
              }

}push(@seq,$seq);
$seq="";
close F2;

for($c=0;$c<$#seq;$c++){
           my $name=$seqname[$c];
           my $seqstring=$seq[$c];
           my @tmp=split(/\t/,$name);
           my $namesubstr=@tmp[0];
	   my $tempstring=@tmp[1];
           my $dirstring=@tmp[2];
	   @tmp=split(/\=/,@tmp[3]);
           my $libstring=@tmp[1];
		$libstring=~s/\s+//g;
           if($libstring!~/^c/){$libstring="codbacnull";}
           if($libstring eq ""){$libstring="codbacnull";}
#	  open(DATA,">>$libstring.454.fna") || die "Couldn't open file file.txt, $!";
	  open(DATA,">>$libstring.454.qual") || die "Couldn't open file file.txt, $!";
	  print ">$libstring\t$name\n";   
	  print DATA"$name\n$seqstring";   
	  close DATA;
#        else{print}
}

