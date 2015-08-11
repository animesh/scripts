#!/usr/bin/perl
print "program for picking up seqs with \>4 in particular periodicity \n";
if( @ARGV ne 1){die "\nUSAGE\t\"ProgName MultSeqFile\"\t\n\n\n";}
$file = shift @ARGV;
#$n= shift @ARGV;
$n=3;
$f=1/$n;
use Math::Complex;
$pi=pi;
$i=sqrt(-1);
open (F, $file) || die "can't open \"$file\": $!";
$seq="";while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\t/,$line);
                $snames=@seqn[0];$snames=~s/>//;1/1;
                chomp $snames;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
push(@seq,$seq);close F;
$filem=$file.".m4"."\.txt";
$filel=$file.".l4"."\.txt";
open(FS1,">$filem");
open(FS2,">$filel");
@base=qw/A T G C/;$ss1=@seq;#print "$ss1\t$ss2\n";
for($c1=0;$c1<$ss1;$c1++)
{
$seq=uc(@seq[$c1]);
$sname=@seqname[$c1];
$foo=$sname."ft"."\.out";
$N=length($seq);
$R=$N%3;
if($R ne 0){$N=$N-$R;}
$ws=$N;
$subseq=$seq;
$c=$subseq=~s/C/C/g;$a=$subseq=~s/A/A/g;$g=$subseq=~s/G/G/g;$t=$subseq=~s/T/T/g;
	@wssplit=split(//,$seq);
	#print "$subseq\t$a\t$t\t$g\t$c\n";
		for($c3=0;$c3<=$#base;$c3++)
		{
		$bvar=@base[$c3];
  			for($c4=0;$c4<=$#wssplit;$c4++)
			{$wsvar=@wssplit[$c4];
				if ($bvar eq $wsvar)
				{
				$sum+=exp(2*$pi*$i*$f*($c4+1));#print "$wsvar\t$bvar\n";
				}
				else{$sum+=0;}
			}
			$sumtotal+=(((1/$ws)**2)*(abs($sum)**2));$sum=0;
		}
		$atgcsq=((1/($ws**2))*($c**2+$a**2+$g**2+$t**2));
		$sbar=(1/$ws)*(1+(1/$ws)-$atgcsq);$atgcsq=0;
		$ptnr=$sumtotal/$sbar;
		$ptnrnew=($ptnr)/($N*$sbar);
		$ptnrnew2=2*$ptnrnew;
		$sumtotal=0;$ll=$c2+$ws-1;
		if($ptnrnew2 >= 4.0)
                   	{
			#print "$sname\t$ptnr\t$ptnrnew\t$ptnrnew2\n";
			print FS1"$sname\t$ptnrnew2\n$seq\n";
			#FT($c2,$ll);
   			}
                else
                      	{
			#print "$sname\t$ptnr\t$ptnrnew\t$ptnrnew2\n";
			print FS2"$sname\t$ptnrnew2\n$seq\n";
			}
}
close FS1;close FS2;
