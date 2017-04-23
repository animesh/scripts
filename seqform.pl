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
open(F,$f);$r=0;
while($l=<F>){chomp $l;$l=uc($l);
	if(($l!~/^>/) and ($l ne "")){
		$line.=$l;
	}
}
close F;
$line=~s/\s+//g;
$sep=58;
@seq=split(//,$line);
for($c1=0;$c1<=$#seq;$c1+=$sep){
	for($c2=$c1;$c2<($c1+$sep);$c2++){
		print "@seq[$c2]"
	}
	print "\n";
}