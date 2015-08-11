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
open (F, $file) || die "can't open \"$file\": $!";
$seq="";
while ($line = <F>) {		
	chomp $line;

	if ($line =~ /^>/){
		#print "Reading\t\tseq no.$c\t$line\n";
		$line=~s/\|/\-/g; $line=~s/\s+//g;#$line=substr($line,1,30);
		push(@seqname,uc($line));	
		#@seqn=split(/\s+/,$line);push(@seqname,$seqn[0]);#$snames=$line;
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

$ftf=$file.".ft.txt";

#$fp=$file.".ftP.txt";
#$fn=$file.".ftN.txt";

#open (FP,">$fp");
#open (FN,">$fn");

open (FTF,">$ftf");

FFT(\@seq,\@seqname);


sub FFT{
	undef @fftcds;undef @fftcdsn;undef @fftncds;undef @fftncdsn;
	$fftseq3=shift;
	$fftseq4=shift;
	@fftseq=@$fftseq3;
	@fftfftseqname=@$fftseq4;
	use Math::Complex;
	$pi=pi;
	$i=sqrt(-1);
	@base=qw/A B C D E F G H I K L M N P Q R S T U V W X Y Z/;
	for($c1=0;$c1<=$#fftseq;$c1++)
	{
		$fooo=$c1+1;	$sname=@fftfftseqname[$c1];$fftseq=uc(@fftseq[$c1]);chomp $fftseq;$fftseq=~s/\s+//g;$N=length($fftseq);
		print "Analysing\tfftseq no.$fooo\t$sname\n";
		print FTF"$sname\t";
		#$seqq=$fftseq;
		until ($fftseq !~ /^A/){$fftseq =~s/^A//;}
		$N=length($fftseq);
		if($N < 3){
		print "$N is less then 3 (Length)\n";
		next;
		}
		$R=$N%6;
		if($R ne 0){
		$N=$N-$R;
		}
	FT(1,$N);
	print FTF"\n";
	}
}

sub FT {
$st=shift;
$sp=shift;
$le=$sp-$st+1;
$subs=substr($fftseq,($st-1),$le);$ws=$sp;$subfftseq=$subs;
$c=$subfftseq=~s/C/C/g;$a=$subfftseq=~s/A/A/g;$g=$subfftseq=~s/G/G/g;$t=$subfftseq=~s/T/T/g;
$b=$subfftseq=~s/B/B/g;$d=$subfftseq=~s/D/D/g;$e=$subfftseq=~s/E/E/g;$f=$subfftseq=~s/F/F/g;
$h=$subfftseq=~s/H/H/g;$ii=$subfftseq=~s/I/I/g;$kk=$subfftseq=~s/K/K/g;$m=$subfftseq=~s/M/M/g;
$l=$subfftseq=~s/L/L/g;$n=$subfftseq=~s/N/N/g;$p=$subfftseq=~s/P/P/g;$q=$subfftseq=~s/Q/Q/g;
$r=$subfftseq=~s/R/R/g;$s=$subfftseq=~s/S/S/g;$v=$subfftseq=~s/V/V/g;$u=$subfftseq=~s/U/U/g;
$w=$subfftseq=~s/W/W/g;$x=$subfftseq=~s/X/X/g;$y=$subfftseq=~s/Y/Y/g;$z=$subfftseq=~s/Z/Z/g;
@subssplit=split(//,$subs);
	for($k=1;$k<=($sp);$k++)
	{
		if (($le/$k) == 6 ||($le/$k) == 2||($le/$k) == 3){
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
			$atgcsq=((1/($ws**2))*($c**2+$a**2+$g**2+$t**2+$b**2+$d**2+$e**2+$f**2+$h**2+$ii**2+$kk**2+$l**2+$m**2+$n**2+$p**2+$q**2+$r**2+$s**2+$w**2+$u**2+$v**2+$x**2+$y**2+$z**2));
			$sbar=(1/$ws)*(1+(1/$ws)-$atgcsq);$atgcsq=0;
			$substss=$sbar;
			$subptnr1=$subsumtotal/$substss;
			$subsumtotal=0;
			$subptnr2=$subptnr1/($sp*$substss);
			$subptnr3=$subptnr2*2;
			$pp=($k)/$le;
			$sp3=$subptnr3;#$sp3=sprintf (1,$subptnr3,2);$sp3=substr($subptnr3,0,3);
			$sname=$sname."-PtNR\t$sp3";
			print "$k\t$sp3\n";
			print FTF"$sp3\t";
#				if($subptnr3 >= 4){
#					print "$subs\nCoding\t$sp3\tLength\t$N\n";
#					print FT">$sname\t$sp3\tLength\t$N\n$subs\n";
#				}
#				else{
#					print "$subs\nNon Coding\t$sp3\tLength\t$N\n";
#					print FT">$sname\t$sp3\tLength\t$N\n$subs\n";
#
#				}			
		}
	}
}



#Group Residues Description
#1 C Cysteine, remains strongly during evolution
#2 M Hydrophobic, sulfur containing
#3 N, Q Amides, polar
#4 D, E Acids, polar, charged
#5 S, T Alcohols
#6 P, A, G Small
#7 I, V, L Aliphatic
#8 F, Y, W Aromatic
#9 H, K, R Bases, charged, positiv