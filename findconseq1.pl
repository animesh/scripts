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
$fc = shift @ARGV;
$fs = shift @ARGV;
open(F1,$fc);
while($l=<F1>){
	chomp $l;
	if($l!~/^>/){
		$pat.=$l;
	}
	$pat=~s/\s+//g;
}
close F1;
open(F2,$fs);
while($l=<F2>){
	chomp $l;
	if($l!~/^>/){
		$seq.=$l;
	}
	$seq=~s/\s+//g;
}
close F2;
print "p-$pat\ns-$seq";
sub PF {
		while ($str =~ /ATTTA|AATAAA|TTCTT/g) {
			my $position = (pos $str) - length($&) +1;
			print "Found $id at position $position\n";
			print "   match:   $&\n";
			print "   pattern: RIS\n";
			my $rem=$position%3;
			my $substrrem;
			$substrrem=substr($str,$position+3*$poschg{$position}-$rem,3);
			my $aa=$aacoded{$substrrem};
			my @temp=@$aa;
			print "Rem: $rem\t$substrrem\t$aa\t$codonprob{$substrrem}\n";
			my $max=0;my $aaamax;my $c;
			for($c=0;$c<=$#temp;$c++){
				if(@temp[$c] ne $substrrem){
					if($codonprob{@temp[$c]}>$max){
						$max=$codonprob{@temp[$c]};
						$aaamax=@temp[$c];
					}
				}
			}
			print "$aaamax\t$codonprob{$aaamax}\t$aacoded{$aaamax}\t$poschg{$position} \t$c\n";
			substr($str,$position+3*$poschg{$position}-$rem,3)=$aaamax;
			$poschg{$position}++;
			if($poschg{$position}>$c){$poscnt=0;last;}
		}
}