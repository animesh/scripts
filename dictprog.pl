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
$file=shift @ARGV;undef @seqname;undef @seq;
open(F,$file)||die "can't open";
while ($line = <F>) {
        chomp ($line);
             	@seqn=split(/\t/,$line);
            	push(@seqname,@seqn[0]);
}
for($fot=0;$fot<=$#seqname;$fot++){
$l=length(@seqname[$fot]);
	if($l==45){print "@seqname[$fot]\n"}
$m{$l}+=1;
}
foreach $w (sort {$a<=>$b} keys %m){
	print "$w\t$m{$w}\n";
	$t+=$m{$w};
}
