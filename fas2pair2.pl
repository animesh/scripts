#!/usr/bin/perl
# fas2pair.pl     sharma.animesh@gmail.com     2009/03/22 01:04:42
#Converts format >codbac-190o01.fb140_b1.SCF length=577 sp3=clipped to >DJS045A03F template=DJS054A03 dir=F library=DJS045
my $lthreshmax=150000;
my $lthreshmin=100000;
my $tcnt=1000;
my $seqlen=650;
my $tes=10;
my $filein=shift @ARGV;
open(F2,$filein);
        
while ($line = <F2>) {
                chomp ($line);
                if ($line =~ /^>/){
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
open(FT,">$filein.artbac.txt");
while($tcnt>0){
	for($c=0;$c<=$#seq;$c++){
		$len=length(@seq[$c]);
		if($len>$lthreshmax){
		 for(my $c=0;$c<$tes;$c++){
		   $cnt++;
			$playlen=$len-$lthreshmin-$seqlen;
			$fpos=rand(1)*$playlen;
			$rpos=$fpos+$lthreshmin;
		   my @tmp=split(/\s+/,@seqname[$c]);
		   my $name=@seqname[$c];
		   $name=~s/\>|\s+//g;
		   my $namesubstr=@tmp[0];
		   my $template="$namesubstr-$fpos-$rpos";
		   my $dirf="F";
		   my $dirr="R";
		   my $libstring=$namesubstr;
				print FT">S.$sno.$totalcnt.$coverage.$window.$wseqlen.$slnamews\n";
				$fseq=substr($seq[$c],$fpos,$seqlen);
				$rseq=substr($seq[$c],$rpos,$seqlen);
				print "$name\ttemplate=$template\tdir=$dirf\tlibrary=$libstring\n$fseq\n";    
				print "$name\ttemplate=$template\tdir=$dirr\tlibrary=$libstring\n$rseq\n";    
			}
		}
	}
$tcnt-=$tes;
}
close FT;
