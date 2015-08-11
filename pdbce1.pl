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

%t2o = (
      'ALA' => 'A',
      'VAL' => 'V',
      'LEU' => 'L',
      'ILE' => 'I',
      'PRO' => 'P',
      'TRP' => 'W',
      'PHE' => 'F',
      'MET' => 'M',
      'GLY' => 'G',
      'SER' => 'S',
      'THR' => 'T',
      'TYR' => 'Y',
      'CYS' => 'C',
      'ASN' => 'N',
      'GLN' => 'Q',
      'LYS' => 'K',
      'ARG' => 'R',
      'HIS' => 'H',
      'ASP' => 'D',
      'GLU' => 'E',
    );

$f=shift @ARGV;
open(F,$f)||die "no such file $f";;

while($l=<F>){
	chomp $l;
	$c++;
	if($l=~/^\# 1: /){
		@t=split(/\s+/,$l);
		$n1=@t[2];
	}
	if($l=~/^\# 2: /){
		@t=split(/\s+/,$l);
		$n2=@t[2];
	}
	if($l!~/^\#/ && $l ne ""){
		@t=split(/\s+/,$l);
		#print "$c\t@t[2]\n";
		@t[2]=~s/\s+//g;
		if(@t[0] ne ""){
			$seq{@t[0]}.=@t[2];
		}

		if($l=~/^\s+/){
			$symbol=@t[1];
			#print "$c\t$symbol\n";
			if($symbol ne ""){
				$seq{"sym"}.=$symbol;
			}
		}
#		if($symbol ne ""){
#			@res=split(//,@t[2]);
#		}
#		for($a=0;$a<=$#s;$a++){
#			if(@s[$a] ne "|"){
#				print "$c\t@s[$a]\n";
#			}
#		}
	}
}
close F;

foreach  (keys %seq) {
	$keyn=$_;
	if($keyn ne "sym" and $n1 eq $keyn){
		@seq1=split(//,$seq{$_});
	}
	elsif($keyn ne "sym" and $n2 eq $keyn){
		@seq2=split(//,$seq{$_});
	}
	else{
		$len=length($seq{$_});
		@sym=split(//,$seq{$_});
	}
	#print "$n1\t$n2\t$_\t$keyn\n"
}


$file = shift @ARGV;

open(FPDB,$file)||die "no such file $file";
while($l=<FPDB>){
	if($l=~/^ATOM/){
		@t=split(//,$l);
		$nm=@t[0].@t[1].@t[2].@t[3];$rn=@t[12].@t[13].@t[14].@t[15];$ch=@t[21];$c9=0;
		if($nm=~/ATOM/ and $rn=~/CA/ and $ch eq "A"){
			$pos=@t[22].@t[23].@t[24].@t[25]+0;
			$s1=$t2o{@t[17].@t[18].@t[19]}."-".@t[21]."-".$pos;
			$x=@t[30].@t[31].@t[32].@t[33].@t[34].@t[35].@t[36].@t[37]+0;
			$y=@t[38].@t[39].@t[40].@t[41].@t[42].@t[43].@t[44].@t[45]+0;
			$z=@t[46].@t[47].@t[48].@t[49].@t[50].@t[51].@t[52].@t[53]+0;
			$s2=$x."\t".$y."\t".$z;
			$aac{$c9}=$s1;
			$name=@t[17].@t[18].@t[19];
			push(@cordx,$x);push(@cordy,$y);push(@cordz,$z);push(@aapdb,$s1);
			$c9++;
			#print "$name\t$s2\n";
		}
	}
}
close FPDB;

print "POS\t$n1\tSYM\t$n2\tX\tY\tZ\n";

for($a=0;$a<$len;$a++){
	$pos=$a+1;
	if(@sym[$a] ne "|"){
		print "$pos\t@seq1[$a]\t@sym[$a]\t@seq2[$a]\t@cordx[$a]\t@cordy[$a]\t@cordz[$a]\t@aapdb[$a]\n";
	}
}
