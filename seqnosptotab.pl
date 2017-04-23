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
open(F,$f);
while($l=<F>){
	chomp $l;
		@t=split(/,/,$l);
		for($c=0;$c<$#t;$c++){
			print "@t[$c],";
		}
		@t=split(//,@t[$c]);
		for($c=0;$c<$#t;$c++){
			print "@t[$c],";
		}
	print "@t[$c]\n";
}
		for($c=0;$c<$#t;$c++){
			print "C-$c,";
		}
			print "C-$c\n";

