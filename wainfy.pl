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
if( @ARGV ne 1){die "\nUSAGE\t\"ProgName MultSeqFile\t\n\n\n";}
$file = shift @ARGV;
use Math::Complex;
$pi=pi;
#$i = Math::Complex->make(0, 0);
$i=sqrt(-1);
open (F, $file) || die "can't open \"$file\": $!";
$seq="";while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\s+/,$line);
                $snames=@seqn[0];$snames=~s/>//;1/1;
                chomp $snames;$snames=~s/\s+//g;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}

push(@seq,$seq);close F;
@base=qw/A T G C/;$ss1=@seq;#

#print "$ss1\t$snames\n$seq\n";
for($c1=0;$c1<$ss1;$c1++)
{
$seq=uc(@seq[$c1]);
$sname=@seqname[$c1];
$foo=$sname."ft"."\.out";
#open FO,">$foo";
$N=length($seq);

$R=$N%3;
#print "$N\t";
if($R ne 0){$N=$N-$R;}
FT(1,$N);
	sub FT {
	#print "in the loop!\n";
	$st=shift;
	$sp=shift;
	$le=$sp-$st+1;
	$subs=substr($seq,($st-1),$le);$ws=$sp;$subseq=$subs;
	$c=$subseq=~s/C/C/g;$a=$subseq=~s/A/A/g;$g=$subseq=~s/G/G/g;$t=$subseq=~s/T/T/g;
	$sfo=$sname."\.fted\.out";
#	open(SFO,">$sfo");
	@subssplit=split(//,$subs);
		
		for($k=1;$k<=($sp/2);$k++)
		 {#print "$subsum\n";
                
		if ($le/$k == 3)
			{for($c6=0;$c6<=$#base;$c6++)
		 	{
			$bvar=@base[$c6];
			#print "op!$c6\t$bvar\n";
			for($c7=0;$c7<=$#subssplit;$c7++)
			{$wsvar=@subssplit[$c7];$c70=$c7+1;#if($c70 ==1){next;}#print "$subsum\n";
				if ($bvar eq $wsvar)
				{	#print "$k\t$bvar\t$wsvar\n2\*$pi\* $i \*\($k\/$le\)\*\($c70\)\n";
					$subsum+=exp((2)*$pi*$i*($k/$le)*($c70));
					#print "$k\t$bvar\t$wsvar\n2\*$pi\* $i \*\($k\/$le\)\*\($c7\+1\)\n";
				}
				else{$subsum+=0;#print "$k\t$bvar\t$wsvar\n\n\n";
				}
			}
			if($subsum){$subsumtotal+=(((1/$le)**2)*(abs($subsum)**2));}
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
		1/1;
		#if ($le/$k == 3)
		#{
		$pp=($k)/$le;if($subptnr3 >= 4){
		print "$sname\t$pp\t$subptnr1\t$subptnr2\t$subptnr3\n";}
		#if($pp eq (1/3)){print $pp\t$subptnr3\n";}
				else {
				print "PTNR \< 4\n$sname\t$pp\t$subptnr1\t$subptnr2\t$subptnr3\n";}
		}
		}#undef @ssts;
		#print "S(f) to Frequency written to file $sfo\n";
		close SFO;
	}
}
