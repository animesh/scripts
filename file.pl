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

$f= shift @ARGV;
$ff=FO($f);
print "\n\t__________ Formatted file written to \'$f2\' ________\n";
sub FO {
$f1=shift;
open F1,$f1;$f2=$f1.".out";
open F2,">$f2";
while($l1 = <F1>){
	chomp $l1;
	print F2"$l1\n";
	}
close F1;close F2;
return $f2;
}

sub gaus {
    $i=shift;	
    $r = sqrt(-2*log(1.0-$i));
    $theta = 2*$pi*$r;
    return $r*cos($theta);       
} 