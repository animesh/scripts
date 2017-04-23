#!/usr/bin/perl
if( @ARGV ne 3){die "\nUSAGE\t\"ProgName MultSeqFile N-basedPeriodicity\t\n\n\n";}
$file = shift @ARGV;$cp=0;$cnp=0;
$k = shift @ARGV;
#$ws = shift @ARGV;
use Math::Complex;
$pi=pi;
$i=sqrt(-1);
$f=(1/$k);
open (F, $file) || die "can't open \"$file\": $!";
$seq="";while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\s+/,$line);
                $snames=@seqn[0];$snames=~s/>//;1/1;$snames=~s/\|/ /g;1/1;
                chomp $snames;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
push(@seq,$seq);close F;$fom4=$file.".morethen4";$fol4=$file.".lessthen4";
open(FS1,">$fom4");
open(FS2,">$fol4");
$foo=$file.".separatedvalues";
open F,">$foo";
@base=qw/A T G C/;$ss1=@seq;#print "$ss1\t$ss2\n";
for($c1=0;$c1<$ss1;$c1++)
{
$seq=uc(@seq[$c1]);
$sname=@seqname[$c1];
#$foo=$sname."ft"."\.out";
#open FO,">$foo";
$N=length($seq);
$R=$N%3;
if($R ne 0){$N=$N-$R;}
$ws=$N;
$len=($N-$ws+1);
        for($c2=1;$c2<=$len;$c2++)
        {
	$c22=$c2+$ws-1;
	$rn=$sname."\.".$c2."\-".$c22."\.fted";
	#open(FS1,">$rn");
        $subseq=substr($seq,($c2-1),($ws));#$ll=length($subseq);
        @wssplit=split(//,$subseq);#print "$seq1\n";
        #foreach $temp (@window){print "$temp\n";}
	$c=$subseq=~s/C/C/g;$a=$subseq=~s/A/A/g;$g=$subseq=~s/G/G/g;
	$t=$subseq=~s/T/T/g;
                for($c3=0;$c3<=$#base;$c3++)
                {
                $bvar=@base[$c3];
                        for($c4=0;$c4<=$#wssplit;$c4++)
                        {$wsvar=@wssplit[$c4];
                                if ($bvar eq $wsvar)
                                {
                                $sum+=exp(2*$pi*$i*$f*($c4+1));#print"$wsvar\t$bvar\n";
                                }
                                else{$sum+=0;}
                        }
                        $sumtotal+=(((1/$ws)**2)*(abs($sum)**2));$sum=0;
                }$atgcsq=((1/($ws**2))*($c**2+$a**2+$g**2+$t**2));
                $sbar=(1/$ws)*(1+(1/$ws)-$atgcsq);$atgcsq=0;
                $ptnr=$sumtotal/$sbar;
                $ptnrnew=($ptnr)/($N*$sbar);
                $ptnrnew2=2*$ptnrnew;
                $sumtotal=0;$ll=$c2+$ws-1;
                if($ptnrnew2 >= 4.0)
                        {
                	#print "Window Analysis of $sname (range:$c2 to $ll):Peak 2 NoiseRatio is $ptnr\t$ptnrnew\t$ptnrnew2\n";
                        print FS1"$sname\t$ptnr\t$ptnrnew\t$ptnrnew2\n";$cp++;
			}
		else	{
			print FS2"$sname\t$ptnr\t$ptnrnew\t$ptnrnew2\n";$cnp++;
			}
	}
}

print F"$file\nMt4\tLt4\n";
print F"$cp\t$cnp\n";$cp=0;$cnp=0;
close F;close FS1,close FS2;