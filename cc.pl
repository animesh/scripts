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
$f = shift @ARGV;open F,$f;
while ($l=<F>) {
	$c++;
	#if($c%1 == 0)
	#{
		@t1=split (/\s+/,$l);
		for($c1=0;$c1<=$#t1;$c1++){
			$c2=$c1+1;
			$sum{$c2}=@t1[$c1];	
	#	}
		#print $l;

	}
}

foreach $q (sort {$sum{$b} <=> $sum{$a}} keys %sum){
	$c3++;@t9=split(/\t/,$q);
	#@t10=split(/\s+/,@t9[0]);
	#if($c3<=$top){
		print "$c3\t$q\t$sum{$q}\n";
	#	}
	}
