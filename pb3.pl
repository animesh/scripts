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


use Math::Complex;
$a=1;$b=1;$c=1;$d=1;$e=1;$pi=Pi;
$n= shift @ARGV;
	for($x=1;$x<=$n;$x++)
	{
	$rnd=rand($x);
	$g=gaus($rnd);
	$y=$a*sin($b*$pi*($x/$n))+$c*sin($d*$pi*($x/$n))+$rnd;
	print "$x\t$y\n";
	}

sub gaus {
    $i=shift;	
    $r = sqrt(-2*log(1.0-$i));
    $theta = 2*$pi*$r;
    return $r*cos($theta);       
} 