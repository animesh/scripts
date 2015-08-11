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
print "please do\n";
@chains=qw/A B C D E F G/;
$cnt1=0;
foreach  (@chains) {
	$chain=$_;
	open(F,$f);
	$pdbf="oelt";
	$cnt2=525*$cnt1;
	while($l=<F>){
		chomp $l;
		if($l=~/^[0-9]/){
			@t=split(/\t/,$l);
			$position=@t[0]-1+$cnt2;
			$resaa=@t[1];
			@t=split(/\-/,$resaa);
			$to=@t[0];
			$from=@t[2];
			print "\$sel2 = select in \"$pdbf\" res \"$from\" and chain \"$chain\" and pos $position\;\n";
			print "mutate \$sel2 to \"$to\"\;\n";
		}
	}
	close F;
	$cnt1++;
}
#$sel2 = select in "oelt" res "K" and chain "A" and pos 2;
#mutate $sel2 to "L";
print "print \"nb residues in motif:  \"  + (string)selcount of \"oelt\"\;\n";
print "thank you\n";
