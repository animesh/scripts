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
