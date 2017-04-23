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

if(@ARGV==1){
	$file=shift @ARGV;
}

else{
	die"Program Usage:perl prog_file_name fasta_file_name\n";
}

open F, "$file" or die "Can't open $f : $!";

while($line=<F>){
	chomp $line;
	if($line!~/^>/){
		$l.=$line;
	}
}

push(@seq,(substr($l,0,length($l))));
push(@seq,(substr($l,1,length($l))));
push(@seq,(substr($l,2,length($l))));
$lr=reverse($l);
$lr=~tr/ATGC/TACG/;
push(@seq,(substr($lr,0,length($lr))));
push(@seq,(substr($lr,1,length($lr))));
push(@seq,(substr($lr,2,length($lr))));
Translate();
sub Translate{

	%c2a = (
			'TTT' => 'F','TTC' => 'F','TTA' => 'L','TTG' => 'L',
			'TCT' => 'S','TCC' => 'S','TCA' => 'S','TCG' => 'S',
			'TAT' => 'T','TAC' => 'T','TAA' => 'stop','TAG' => 'stop',
			'TGT' => 'C','TGC' => 'C','TGA' => 'stop','TGG' => 'W',
			
			'CTT' => 'L','CTC' => 'L','CTA' => 'L','CTG' => 'L',
			'CCT' => 'P','CCC' => 'P','CCA' => 'P','CCG' => 'P',
			'CAT' => 'H','CAC' => 'H','CAA' => 'Q','CAG' => 'Q',
			'CGT' => 'R','CGC' => 'R','CGA' => 'R','CGG' => 'R',
			
			'ATT' => 'I','ATC' => 'I','ATA' => 'I','ATG' => 'M',
			'ACT' => 'T','ACC' => 'T','ACA' => 'T','ACG' => 'T',
			'AAT' => 'N','AAC' => 'N','AAA' => 'K','AAG' => 'K',
			'AGT' => 'S','AGC' => 'S','AGA' => 'R','AGG' => 'R',
			
			'GTT' => 'V','GTC' => 'V','GTA' => 'V','GTG' => 'V',
			'GCT' => 'A','GCC' => 'A','GCA' => 'A','GCG' => 'A',
			'GAT' => 'D','GAC' => 'D','GAA' => 'E','GAG' => 'E',
			'GGT' => 'G','GGC' => 'G','GGA' => 'G','GGG' => 'G',
	);

	for ($c1=0;$c1<=$#seq;$c1++) {
		$se=@seq[$c1];
		@t=split(//,$se);
		if($c1<3){
			$cnt=$c1+1;
			print ">Translation for Forward Frame + $cnt :\n" 
		}
		else{
			$cntrev=$c1-2;
			print ">Translation for Reverse Frame - $cntrev:\n" 
		}
		for ($c2=0;$c2<=$#t;$c2=$c2+3) {
			$co1=$c2a{@t[$c2].@t[$c2+1].@t[$c2+2]};
			print "$co1";    
		}
		print "\n";
	}

}