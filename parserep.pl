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
use strict;
my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
open(F,$main_file_pattern)||die "can't open";
my $line;
my @temp;
my $lineno;
while ($line = <F>) {
	$lineno++;
        chomp ($line);
        if ($line ne ""){
#             push(@seqname,$snames);
		@temp=split(/\t/,$line);
		my $lentemp=@temp;
		#print "$lentemp\t$lineno\n";
		if($lentemp==2){
			print "$lentemp\t$lineno\n";
		}
      	} 
	else {
	}
}
close F;

my $w;my %m;my $fot;my $t;
my $fresall=$main_file_pattern.".parserep.out";
open(FRA,">$fresall");
my $fot;
for($fot=0;$fot<=$#temp;$fot++){
}
close FRA;
