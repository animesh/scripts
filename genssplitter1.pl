#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Code base of Animesh Sharma [ sharma.animesh@gmail.com ]

#!/usr/bin/perl
print "program for picking up seqs with \>4 in particular periodicity \n";
if( @ARGV ne 2){die "\nUSAGE\t\"ProgName MultSeqFile ?baseperiodicity\"\t\n\n\n";}
$file = shift @ARGV;
$n= shift @ARGV;
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
$filem=$file.".m4";
$filel=$file.".l4";
open(FS1,">$filem");
open(FS2,">$filel");
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
$ws=$N;
$len=($N-$ws+1);
	for($c2=1;$c2<=$len;$c2++)
	{
	$subseq=substr($seq,($c2-1),($ws));#$ll=length($subseq);
	@wssplit=split(//,$subseq);#print "$seq1\n";
	#foreach $temp (@window){print "$temp\n";}

$c=$subseq=~s/C/C/g;$a=$subseq=~s/A/A/g;$g=$subseq=~s/G/G/g;$t=$subseq=~s/T/T/g;
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
			print "$sname\t$ptnr\t$ptnrnew\t$ptnrnew2\n";
			print FS1"$sname\t$ptnrnew2\n$seq\n";
			FT($c2,$ll);
   			}
                else
                      	{
			print "$sname\t$ptnr\t$ptnrnew\t$ptnrnew2\n";
			print FS2"$sname\t$ptnrnew2\n$seq\n";
			}
	} # End else
	sub FT {
	$st=shift;
	$sp=shift;
	$le=$sp-$st+1;
	$subs=substr($seq,($st-1),$le);
	$sc=$subs=~s/C/C/g;$sa=$subs=~s/A/A/g;$sg=$subs=~s/G/G/g;$st=$subs=~s/T/T/g;
			$satgcsq=((1/($le**2))*($sc**2+$sa**2+$sg**2+$st**2));
			$ssbar=(1/$le)*(1+(1/$le)-$satgcsq);$satgcsq=0;
	$sfo1=$sname."b".$st."e".$sp."out";
	$sfo2=$sname."b".$st."e".$sp."outnew";
	open(SFO,">$sfo1");
	open(SFONEW,">$sfo2");
	@subssplit=split(//,$subs);
		for($k=1;$k<=($le/2);$k++)
		{
		 for($c6=0;$c6<=$#base;$c6++)
		 {
			$bvar=@base[$c6];
  			for($c7=0;$c7<=$#subssplit;$c7++)
			{$wsvar=@subssplit[$c7];
				if ($bvar eq $wsvar)
				{
				$subsum+=exp(2*$pi*$i*($k/$le)*($c7+1));
				#print"$wsvar\t$bvar\n";
				}
				else{$subsum+=0;}
			}
			$subsumtotal+=(((1/$le)**2)*(abs($subsum)**2));
			$subsum=0;
		 }
		push(@ssts,$subsumtotal);
		$sptnr0=$subsumtotal/$ssbar;
		$sptnr1=$sptnr0/($le*$ssbar);
		$sptnr2=$sptnr1*2;
		$ff=$k/$le;
		$substs+=$subsumtotal;
		print SFONEW"$ff\t$sptnr0\t$sptnr1\t$sptnr2\n";$subsumtotal=0;
		}$substss=2*($substs/$le);$substs=0;
		#for($c8=0;$c8<=$#ssts;$c8++)
		#{
		#$sptnr0=@ssts[$c8]/$substss;1/1;$pp=($c8+1)/$le;
		#$sptnr1=$sptnr0/($le*$ssbar);
		#$sptnr2=(2*$sptnr1);
		#print SFO"$pp\t$sptnr0\t$sptnr1\t$sptnr2\n";
		#}
		print "S(f) to Frequency written to file $sfo1 and $sfo2\n";
		undef @ssts;close SFO;
	}
}
close FS1;close FS2;close SFO;close SFONEW;
