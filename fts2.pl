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
$file=shift @ARGV;
open(F,$file)||die "can't open";
while ($line = <F>) {
        chomp ($line);
        @n=split(/\t/,$line);@n[4]=~s/\s+//g;
#	foreach $w (@n){print "$c=>$w\n";$c++}$c=0;
	if(@n[4] <= 1){
	$lto{@n[2]}=@n[4];}	
	elsif(@n[4] >= 9){
	$mtn{@n[2]}=@n[4];}
	
}
#foreach $w (sort {$a <=> $b} keys %m){print "$w\t$m{$w}\n";}
#foreach $w (keys %mtn){print "$w\t$mtn{$w}\n";}
foreach $w (keys %lto){print "$w\t$lto{$w}\n";}
