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
if((@ARGV)!=1){die "USAGE: progname_name OFS-status-file\n";}
$f=shift @ARGV;
open(F,$f);
while($l=<F>){
	chomp $l;
	$l=~s/^\s+//g;
	$l=~s/\s+/\t/g;
	@t1=split(/\t/,$l);
	if((@t1)==6){
		$iter{(@t1[0]+0)}=@t1[1]+0;
		$iterval=(@t1[0]+0);
		#print "@t1[0]=>$iter{@t1[0]}=>\t$l\n";
	}
	if((@t1)==2){
		$gene{(@t1[0]+0)}=@t1[1]+0;
		#$matrixofs[(@t1[1]+0)][$iterval]=@t1[2]+0;
		#print "@t1[0]=>$gene{@t1[0]}=>\t$l\n";
	}
}
close F;

#foreach  $i1 (%iter) {
#	foreach $g1 (%gene) {
#		print "$matrixofs[$g1][$i1],";
#	}
#	print "\n";
#}

$foo=$f.".out";
open(FO,">$foo");
foreach $g1 (sort { $gene{$b} <=> $gene{$a}} keys %gene) {
	print FO"$g1\t$gene{$g1}\n";
}
close FO;
