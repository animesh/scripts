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

#!/usr/local/bin/perl
## Time-stamp: "5/1/2005" ##

$wfile='dna_chimes.mid';
use MIDI::Simple;
set_tempo 500000;  
patch_change 1, 8; 
$file="ecolk12.fas";

use Math::Complex;
$pi=pi;
$i=sqrt(-1);
@base=qw/G T A C/;
$window=90;
$threshold=3;


OPENFAS($file);
new_score;
CRTDNAMUS();
write_score("$wfile");
exit;

sub CRTDNAMUS{
	for ($c1=0;$c1<=$#seq;$c1++) {
		$sn=@seqname[$c1];
		$se=@seq[$c1];
		$len=length($se);$len=500;
		for ($c2=0;$c2<$len;$c2=$c2+$window) {
			$dnastr=substr($se,$c2,$window);
			undef @ptnr; undef $mash;
			print "$file: $c1\t$c2\t$le\n";
			FTT($dnastr);
			for($c3=0;$c3<=$#ptnr;$c3++){
				@t1=split(/\./,@ptnr[$c3]);				
				$chann1=@t1[0]+1;$chann1="c".$chann1;
				@t2=split(//,@t1[1]);
				$note1=(@t2[0])+(@t2[1]*10);$note1="n".$note1;
				$octave1=(@t2[2]+1);$octave1="o".$octave1;
				noop $chann1, f, $octave1;
				n sn, $note1;    
			}
		}
	}
}

sub OPENFAS{
	$file = shift;
	open (F, $file) || die "can't open \"$file\": $!";
	$seq="";
	while ($line = <F>) {chomp $line;
		if ($line =~ /^>/){
			push(@seqname,$line);	
			if ($seq ne ""){
				push(@seq,$seq);
						$seq = "";
					}
			}
		 else {$seq=$seq.$line;
			}
	}
	push(@seq,$seq);
	close F;
}



sub FTT {
	$dnastr=shift;$dnastr=uc($dnastr);
	until ($dnastr !~ /^G/){$dnastr =~s/^G//;}
	$ws=length($dnastr);
	$subfftseq=$dnastr;
	$subs=$subfftseq;
	$c=$subfftseq=~s/C/C/g;$a=$subfftseq=~s/A/A/g;$g=$subfftseq=~s/G/G/g;$t=$subfftseq=~s/T/T/g;
	@subssplit=split(//,$subs);
	$sp=$ws;$le=$ws;
		for($k=1;$k<=($sp/2);$k++){	
				for($c6=0;$c6<=$#base;$c6++){
				$bvar=@base[$c6];
					for($c7=0;$c7<=$#subssplit;$c7++){
					$wsvar=@subssplit[$c7];
						if ($bvar eq $wsvar){
							$subsum+=exp(2*$pi*$i*($k/$le)*($c7+1));
						}
						else{
							$subsum+=0;
						}
					}
				$subsumtotal+=(((1/$le)**2)*(abs($subsum)**2));
				$subsum=0;
				}
				$atgcsq=((1/($ws**2))*($c**2+$a**2+$g**2+$t**2));
				$sbar=(1/$ws)*(1+(1/$ws)-$atgcsq);$atgcsq=0;
				$substss=$sbar;
				$subptnr1=$subsumtotal/$substss;
				$subsumtotal=0;
				$subptnr2=$subptnr1/($sp*$substss);
				$subptnr3=$subptnr2*2;
				$pp=($k)/$le;
				$sp3=$subptnr3;$sp3=sprintf (1,$subptnr3,2);$sp3=substr($subptnr3,0,3);
				push(@ptnr,$subptnr3);$mash{$subptnr3}=$pp;
		}
}