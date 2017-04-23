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
 $enz{1}="Trypsin";
 $enz{2}="Lys-C";
 $enz{3}="Arg-C";
 $enz{4}="Asp-N";
 $enz{5}="V8-bicarb";
 $enz{6}="V8-phosph";
 $enz{7}="Chymotrypsin";
 $enz{8}="CNBr";
for($c=1;$c<9;$c++){
	$in="seq_xen.fas";
	$out=$in.".$c.out";
	system("digest $in -menu $c -out $out");
}
#$fo=">digest_result.txt";
#for($c=1;$c<9;$c++){
#	$in="seq_xen.fas";
#	$out=$in.".$c.out";
#	
#}
