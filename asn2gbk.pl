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

system("ls -1 *.1.asn1 > tempfile1");
open(FT1,"tempfile1");
open(FT,">temp.txt");

my $cnt=0;
while(my $tfl1=<FT1>){
	$cnt++;
	chomp $tfl1;
	print "Converting $tfl1...\t";
    if($tfl1=~/asn1$/){
	my @temp=split(/\./,$tfl1);
	my $foo=@temp[0].".gb";
	system("asn2gb.Win32 -i $tfl1 -o $foo -f b");
    }
	print "Done\n";
}
close FT1;



