#!/usr/bin/perl
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

use strict;
use lib "/home/fimm/ii/ash022/bioperl/";
use Bio::SeqIO;

my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
my $other_file_pattern=shift @ARGV;chomp $other_file_pattern;
$main_file_pattern = "FCRLHFZ02.sff.fna";
$other_file_pattern = "NC_010336.fna";

my $line;
my $seq;my @seq;
my @gseq;
my $seqname;my @seqname;my $snames;
my @gseqname;



open(F,$main_file_pattern)||die "can't open";
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


open(FO,$other_file_pattern)||die "can't open";
while ($line = <FO>) {
        chomp ($line);
        if ($line =~ /^>/){
		$snames=$line;
		chomp $snames;
             push(@gseqname,$snames);
                if ($seq ne ""){
              push(@gseq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}push(@gseq,$seq);
$seq="";
close FO;

my $w;my %m;my $fot;my $t;
my $fresall=$main_file_pattern.$other_file_pattern.".s2g.txt";
open(FRA,">$fresall");



for($fot=0;$fot<=$#seq;$fot++){
my $cntm=@gseq[0]=~s/@seq[$fot]/@seq[$fot]/g;
$m{$fot}++;
@seqname[$fot]=~s/\s+/\_/g;
print FRA"@seqname[$fot]\t$cntm\n";
}
close FRA;
#foreach $w (sort {$a<=>$b} keys %m){print FR"$w\t$m{$w}\n";$t+=$m{$w};}


