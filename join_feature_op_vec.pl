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
$f1=shift @ARGV;
$f2=shift @ARGV;
open(F1,$f1);
open(F2,$f2);
open(FO,">$f1.$f2.j.txt");

while($l1=<F1>){
	chomp $l1;
	push (@t1,$l1);
	print $c1++;
}
print "\n";
while($l2=<F2>){
	chomp $l2;
	push (@t2,$l2);
	print $c2++;
}
print "\n";
if($c1==$c2){
for($c=0;$c<=$#t1;$c++){
	print FO"@t1[$c]\t@t2[$c]\n";
}
}
else {die"file length not equal!"}