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
$f=shift @ARGV;
$fea=shift@ARGV
$opv=shift@ARGV;
$file1=$f."_featv.out";
$file2=$f."_op.out";
open(F,$f);
open(F1,>$file1);
open(F2,>$file2);

while($l=<F>){
@t=split(/\s+/,$l);
	if(@t==($fea+$opv)){
		for($c=0;$c<$fea;$c++){
		print F1"@t[$c]\t";
		}
		print F1"\n";
		for($c=$fea;$c<($fea+$opv);$c++){
		print F2"@t[$c]\t";
		}
		print F2"\n";

	}
}
