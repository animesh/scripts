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
use lib "/Home/siv11/ash022/bioperl/";
use Bio::SeqIO;


my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
my $start=shift @ARGV;
open(F,$main_file_pattern)||die "can't open";
my $seq;
my @seq;
my $fot;
my $line;
my @seqname;
my $snames;
while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
		$snames=$line;
		chomp $snames;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}push(@seq,$seq);
$seq="";
close F;

my $fo=$main_file_pattern.".$start.out";
open(FRA,">$fo")||die "can't open";

for($fot=$start;$fot<=$#seq;$fot++){
print FRA"@seqname[$fot]\n@seq[$fot]\n";

}
close FRA;


