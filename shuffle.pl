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
if(@ARGV!=2){die"USAGE: Input_File Output_File";}
$file1=shift @ARGV;
$file2=shift @ARGV;
open(F2,">$file2");
	open(F1,$file1);
	while($l=<F1>){
	chomp $l;
	push(@filez,$l);
	}		

FYS( \@filez );  

sub FYS {
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}

for($c3=0;$c3<=$#filez;$c3++){
	print F2"@filez[$c3]\n";
}
