#!/usr/bin/perl
if( @ARGV ne 1){die "\nUSAGE\t\"ProgName MultSeqFile\t\n\n\n";}
$file = shift @ARGV;
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
@base=qw/A T G C/;$ss1=@seq;#print "$ss1\t$ss2\n";
for($c1=0;$c1<$ss1;$c1++)
{
$seq=uc(@seq[$c1]);
$sname=@seqname[$c1];
$foo=$sname."ft"."\.out";
open FO,">$foo";
$N=length($seq);
$R=$N%3;
if($R ne 0){$N=$N-$R;}
FT(1,$N);
	sub FT {
	$st=shift;
	$sp=shift;
	$le=$sp-$st+1;
	$subs=substr($seq,($st-1),$le);$ws=$sp;$subseq=$subs;
	$c=$subseq=~s/C/C/g;$a=$subseq=~s/A/A/g;$g=$subseq=~s/G/G/g;$t=$subseq=~s/T/T/g;
	$sfo=$sname."\.fted\.out";
	open(SFO,">$sfo");
	@subssplit=split(//,$subs);
		for($k=1;$k<=($sp/2);$k++)
		 {for($c6=0;$c6<=$#base;$c6++)
		 {
			$bvar=@base[$c6];
  			for($c7=0;$c7<=$#subssplit;$c7++)
			{$wsvar=@subssplit[$c7];
				if ($bvar eq $wsvar)
				{
				$subsum+=exp(2*$pi*$i*($k/$le)*($c7+1));#print"$wsvar\t$bvar\n";
				}
				else{$subsum+=0;}
			}
			$subsumtotal+=(((1/$le)**2)*(abs($subsum)**2));
			$subsum=0;
		 }
		 $atgcsq=((1/($ws**2))*($c**2+$a**2+$g**2+$t**2));
		 $sbar=(1/$ws)*(1+(1/$ws)-$atgcsq);$atgcsq=0;
		 #push(@ssts,$subsumtotal);$substs+=$subsumtotal;
		 $substss=$sbar;
		$subptnr1=$subsumtotal/$substss;
		$subsumtotal=0;
		$subptnr2=$subptnr1/($sp*$substss);
		$subptnr3=$subptnr2*2;
		1/1;$pp=($k)/$le;
		print SFO"$pp\t$subptnr1\t$subptnr2\t$subptnr3\n";
		}#undef @ssts;
		print "S(f) to Frequency written to file $sfo\n";
		close SFO;
	}
}
