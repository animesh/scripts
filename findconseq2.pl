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
	else{
		$pn=$l;
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
#print "p-$pat\ns-$seq";
$pattern=$pat;
$pat=~s/N/\./g;
$pat=~s/W/\[A\|T\]/g;
$pat2=substr($pat,0,9);
print "p -\t$pattern\t$pat\t$pat2\n";
PF($pat2,$seq,$pn);
sub PF {
		my $pattern = shift;
		my $sequence = shift;
		my $patternname = shift;
		while ($sequence =~ /$pattern/g) {
			my $position = (pos $sequence) - length($&) +1;
			print "Found at position:\t$position\t";
			print "pattern:\t$&\t";
			print "$patternname\n";
		}
}