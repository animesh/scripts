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
$thr=10;
%h2a = (
	'I'		 => 		4.5,
	'V'		 => 		4.2,
	'L'		 => 		3.8,
	'F'		 => 		2.8,
	'C'		 => 		2.5,
	'M'		 => 		1.9,
	'A'		 => 		1.8,
	'G'		 => 		-0.4,
	'T'		 => 		-0.7,
	'W'		 => 		-0.9,
	'S'		 => 		-0.8,
	'Y'		 => 		-1.3,
	'P'		 => 		-1.6,
	'H'		 => 		-3.2,
	'E'		 => 		-3.5,
	'Q'		 => 		-3.5,
	'D'		 => 		-3.5,
	'N'		 => 		-3.5,
	'K'		 => 		-3.9,
	'R'		 => 		-4.5,
	'B'		 => 		-3.5,
	'Z'		 => 		-3.5,
	'X'		 => 		0,
	'U'		 => 		1,
);


open (F, $file) || die "can't open \"$file\": $!";
$seq="";
while ($line = <F>) {		
	chomp $line;$line=~s/\|/\-/g; $line=~s/\s+//g;
	if ($line =~ /^>/){
		push(@seqname,uc($line));	
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

$ftf=$file.".hyd.txt";

open (FTF,">$ftf");

for($c1=0;$c1<=$#seq;$c1++)
{
	$fooo=$c1+1;	
	$sname=@seqname[$c1];
	$fftseq=uc(@seq[$c1]);
	$N=length($fftseq);
	if($N%$thr!=0){$N=$N+($thr-$N%$thr);}

	print "Analysing\tseq no.$fooo\t$N\t$sname\t";
	print FTF"$sname\t";
	CNT();

	print "\n";

	print FTF"\n";

	#$seqq=$fftseq;
#FT(1,$N);
#print FTF"\n";
}




sub CNT{
	$per=int($N/$thr);

	#print "$per";
	$win=0;
	for($x1=0;$x1<$N;$x1+=$per){
		$win++;
		$subs=substr($fftseq,$x1,$per);
		$subfftseq=$subs;
		$perle=length($subs);
		print "$N\t$x1\t$perle\t$subs\t";
		$c=$subfftseq=~s/C/C/g;$a=$subfftseq=~s/A/A/g;$g=$subfftseq=~s/G/G/g;$t=$subfftseq=~s/T/T/g;
		$b=$subfftseq=~s/B/B/g;$d=$subfftseq=~s/D/D/g;$e=$subfftseq=~s/E/E/g;$f=$subfftseq=~s/F/F/g;
		$h=$subfftseq=~s/H/H/g;$i=$subfftseq=~s/I/I/g;$k=$subfftseq=~s/K/K/g;$m=$subfftseq=~s/M/M/g;
		$l=$subfftseq=~s/L/L/g;$n=$subfftseq=~s/N/N/g;$p=$subfftseq=~s/P/P/g;$q=$subfftseq=~s/Q/Q/g;
		$r=$subfftseq=~s/R/R/g;$s=$subfftseq=~s/S/S/g;$v=$subfftseq=~s/V/V/g;$u=$subfftseq=~s/U/U/g;
		$w=$subfftseq=~s/W/W/g;$x=$subfftseq=~s/X/X/g;$y=$subfftseq=~s/Y/Y/g;$z=$subfftseq=~s/Z/Z/g;
	$hyd=$a*$h2a{'A'}+$b*$h2a{'B'}+$c*$h2a{'C'}+$d*$h2a{'D'}+$e*$h2a{'E'}+$f*$h2a{'F'}+$g*$h2a{'G'}+$h*$h2a{'H'}+$i*$h2a{'I'}+$k*$h2a{'K'}+$l*$h2a{'L'}+$m*$h2a{'M'}+$n*$h2a{'N'}+$p*$h2a{'P'}+$q*$h2a{'Q'}+$r*$h2a{'R'}+$s*$h2a{'S'}+$t*$h2a{'T'}+$u*$h2a{'U'}+$v*$h2a{'V'}+$w*$h2a{'W'}+$x*$h2a{'X'}+$y*$h2a{'Y'}+$z*$h2a{'Z'};
		if($perle!=0){$hyd=$hyd/$perle;}
		else{$hyd=$hyd/$per;}
		print "$hyd\t";
		print FTF"$hyd\t";
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

#Amino Acid Name One Letter Code Hydropathy Score
 
#Isoleucine I 4.5 
#Valine V 4.2 
#Leucine L 3.8 
#Phenylalanine F 2.8 
#Cysteine C 2.5 
#Methionine M 1.9 
#Alanine A 1.8 
#Glycine G -0.4 
#Threonine T -0.7 
#Tryptophan W -0.9 
#Serine S -0.8 
#Tyrosine Y -1.3 
#Proline P -1.6 
#Histidine H -3.2 
#Glutamicacid E -3.5 
#Glutamine Q -3.5 
#Asparticacid D -3.5 
#Asparagine N -3.5 
#Lysine K -3.9 
#Arginine R -4.5 
