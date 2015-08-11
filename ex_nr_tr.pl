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
$f1=shift @ARGV;chomp $f1;
$f2=shift @ARGV;chomp $f2;
open F1,$f1||die"cannot open $f1";
open F2,$f2||die"cannot open $f1";

while($l2=<F2>){
	chomp $l2;
	@t6=split(/\s+/,$l2);
	push(@t,@t6[1]);
}

while($l1=<F1>){
	chomp $l1;
	push(@t2,$l1);
}

for ($c=0;$c<=$#t;$c++) {
	print "@t2[@t[$c]-1]\n";
}

close F1;
close F2;
