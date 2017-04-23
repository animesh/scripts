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

$file=shift @ARGV;
open(F,$file);
while($l=<F>){
	if($l=~/^ATOM/){
		$atom++;
		@t=split(/\s+/,$l);
		push(@atoms,@t[1]);
		$xatom{@t[1]}=@t[5];
		$yatom{@t[1]}=@t[6];
		$zatom{@t[1]}=@t[7];
		$atomname{@t[1]}=@t[4];
	}
	if($l=~/^HETATM/){
		$hetatom++;
		@t=split(/\s+/,$l);
		push(@hetatoms,@t[1]);
		$xhatom{@t[1]}=@t[5];
		$yhatom{@t[1]}=@t[6];
		$zhatom{@t[1]}=@t[7];
		$hetatomname{@t[1]}=@t[2];
	}
}
print "ATOM-$atom\tHETATOM-$hetatom\n";
foreach $a (@atoms) {
	foreach $ha (@hetatoms) {
		$ed{"$a-$ha"}=sqrt(($xhatom{$ha}-$xatom{$a})**2+($zhatom{$ha}-$zatom{$a})**2+($yhatom{$ha}-$yatom{$a})**2);
	}
}

print "ATOM-HETATM\tATOMPOS\tHETATMNAME\tEuclidean Distance\n";
foreach $edval (sort { $ed{$a} <=> $ed{$b}} keys %ed) {
	@t=split(/\-/,$edval);
	@t[0]=~s/\s+//g;
	@t[1]=~s/\s+//g;
	if($ed{$edval}<=4){
		print "$edval\t\t$atomname{@t[0]}\t$hetatomname{@t[1]}\t=>\t$ed{$edval}\n";
	}
	else {
		last;
	}
}