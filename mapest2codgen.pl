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

my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
my $other_file_pattern=shift @ARGV;chomp $other_file_pattern;

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

my $fot;
for($fot=0;$fot<=$#seq;$fot++){
#for($fot=0;$fot<1;$fot++){
	$len=length(@seq[$fot]);
	if($len>10000){
	open(FO,">genseq");
	@seqname[$fot]=~s/\>//g;
	print FO">@seqname[$fot]\n@seq[$fot]\n";
	print "Comparing $other_file_pattern to Gen Scaf @seqname[$fot] ...\n";
	my @tmpnm=split(/\s+/,@seqname[$fot]);
	system("/home/animesh/export/EMBOSS-6.3.1/emboss/est2genome $other_file_pattern  genseq -outfile=$other_file_pattern.@tmpnm[0].$main_file_pattern.est2genome");
	}
}

