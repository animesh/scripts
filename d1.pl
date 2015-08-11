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
#libname inform 'D:\animesh\umkc\snp\project_din'; 
#options fmtsearch=(inform);
open(F,"d1.csv");$c=0;
#open(F,"ppar11nov2004.csv");$c=0;
while($l=<F>){
	$ccc=0;
	#if($c>1){last;}
	@t1=split(/\,/,$l);
	#for($cc=0;$cc<=$#t;$cc++){
	#for($cc=214;$cc<=229;$cc++){$ccc++;
	for($cc=213;$cc<=235;$cc++){$ccc++;
	#for($cc=216;$cc<=231;$cc++){$ccc++;
		$t2[$cc][$c]=@t1[$cc];
		#print "$cc\t@t1[$cc]\n";
	}
	$c++;
}
for($c1=213;$c1<=235;$c1++){
	for($c2=0;$c2<=$c;$c2++){
		#$t2[$c1][$c2]=@t1[$cc];
		print "$t2[$c1][$c2]\t";
	}
	print "\n";
}

