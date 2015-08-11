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

$file = shift @ARGV;
open(F,$file)||die "no such file";

%t2o = (
      'ALA' => 'A','VAL' => 'V','LEU' => 'L','ILE' => 'I','PRO' => 'P','TRP' => 'W','PHE' => 'F',
      'MET' => 'M','GLY' => 'G','SER' => 'S','THR' => 'T','TYR' => 'Y','CYS' => 'C','ASN' => 'N',
      'GLN' => 'Q','LYS' => 'K','ARG' => 'R','HIS' => 'H','ASP' => 'D','GLU' => 'E',
);


while($l=<F>){
	$s="";
	if($l=~/^SEQRES/){
		@t=split(//,$l);
		for($c1=19;$c1<=67;$c1=$c1+4) {
		$cs{@t[11]}.=$t2o{@t[$c1].@t[$c1+1].@t[$c1+2]};
		$s.=$t2o{@t[$c1]};
		}
	}
	$seq.=$s;$s="";
	if($l=~/^HELIX/){
		@t=split(//,$l);
		$str=@t[21].@t[22].@t[23].@t[24]+0;
		$stp=@t[33].@t[34].@t[35].@t[36]+0;
		$s=substr($cs{@t[19]},($str-1),($stp-$str+1));
		@t2=split(//,$s);
			for($c2=0;$c2<=$#t2;$c2++){
				$s1=@t2[$c2]."-".@t[19]."-".($str+$c2);$s2="H";
				$aap{$s1}=$s2;
				#print "$str\t$stp\t$s1=>$aap{$s1}\n";
			}
		}
	$s="";

	if($l=~/^SHEET/){
		@t=split(//,$l);
		$str=@t[22].@t[23].@t[24].@t[25]+0;
		$stp=@t[33].@t[34].@t[35].@t[36]+0;
		$s=substr($cs{@t[21]},($str-1),($stp-$str+1));
		@t2=split(//,$s);
			for($c2=0;$c2<=$#t2;$c2++){
				$s1=@t2[$c2]."-".@t[21]."-".($str+$c2);$s2="S";
				$aap{$s1}=$s2;
				#print "$str\t$stp\t$s1=>$aap{$s1}\n";
			}
		}
	$s="";

	if($l=~/^TURN/){
		@t=split(//,$l);
		$str=@t[20].@t[21].@t[22].@t[23]+0;
		$stp=@t[31].@t[32].@t[33].@t[34]+0;
		$s=substr($cs{@t[19]},($str-1),($stp-$str+1));
		@t2=split(//,$s);
			for($c2=0;$c2<=$#t2;$c2++){
				$s1=@t2[$c2]."-".@t[19]."-".($str+$c2);$s2="T";
				$aap{$s1}=$s2;
				#print "$str\t$stp\t$s1=>$aap{$s1}\n";
			}
		}
	if($l=~/^ATOM/){
		@t=split(//,$l);
		$nm=@t[0].@t[1].@t[2].@t[3];$rn=@t[12].@t[13].@t[14].@t[15];
		if($nm=~/ATOM/ and $rn=~/CA/){#$c9++;
			$pos=@t[22].@t[23].@t[24].@t[25]+0;
			$s1=$t2o{@t[17].@t[18].@t[19]}."-".@t[21]."-".$pos;
			$x=@t[30].@t[31].@t[32].@t[33].@t[34].@t[35].@t[36].@t[37]+0;
			$y=@t[38].@t[39].@t[40].@t[41].@t[42].@t[43].@t[44].@t[45]+0;
			$z=@t[46].@t[47].@t[48].@t[49].@t[50].@t[51].@t[52].@t[53]+0;
			$s2=$x.":".$y.":".$z;
			$aac{$s1}=$s2;
			#print "$c9\t$s1=>$aac{$s1}=>$aap{$s1}\n";
		}
	}
}
close F;

$c1=0;$c2=0;
foreach $w1 (keys %aac){$c1++;$c2=0;
	foreach $w2 (keys %aac){$c2++;
		if($w1 ne $w2){
		$val=ED($aac{$w1},$aac{$w2});
		$key="$w1-$w2-$aap{$w1}-$aap{$w2}";
		$sum{$key}=$val;
		#print "$w1:$w2\t\"$aac{$w1}:$aac{$w2}\"\t$val \"$aap{$w1}:$aap{$w2}\"\n";
		}
	}
}
foreach $q (sort {$sum{$a} <=> $sum{$b}} keys %sum){
	print "$q\t$sum{$q}\n";
}

sub ED{
	$val1=shift;
	$val2=shift;
	
	@t1=split(/\:/,$val1);
	@t2=split(/\:/,$val2);

	$dis=sqrt((@t1[0]-@t2[0])**2+(@t1[1]-@t2[1])**2+(@t1[2]-@t2[2])**2);
	return $dis;
}

