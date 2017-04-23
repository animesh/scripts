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

my %Count; # stores the counts of each symbol
my $total = 0; # total symbols counted
my $l=shift @ARGV;chomp $l;
open (F,$l);
while($line=<F>){
foreach my $char (split(//, $line)) 
	{ # split the line into characters
	$Count{$char}++; # add one to this character count
	$total++; # add one to total counts
	}
}
	my $H = 0; # H is the entropy
	foreach my $char (keys %Count) 
	{ # iterate through characters
	my $p = $Count{$char}/$total; # probability of character
	$H += $p * log($p); # p * log(p)
	}
$H = -$H/log(2); # negate sum, convert base e to base 2
print "H = $H bits\n"; # output