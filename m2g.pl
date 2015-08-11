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
my $fresall=$main_file_pattern.$other_file_pattern.".resall.txt";
open(FRA,">$fresall");



for($fot=0;$fot<=$#seq;$fot++){
my ($per_sim_res,$length_res,$other_start_res,$other_end_res,$dir)=seqcomp(@seq[$fot],@gseq[0],@seqname[$fot],@gseqname[0]);
my $l=$per_sim_res;
$m{$l}+=1;
@seqname[$fot]=~s/\s+/\_/g;
print FRA"@seqname[$fot]\t$per_sim_res\t$length_res\t$other_start_res\t$other_end_res\t$dir\n";

}
close FRA;

my $fres=$main_file_pattern.$other_file_pattern.".res.txt";
open(FR,">$fres");


foreach $w (sort {$a<=>$b} keys %m){print FR"$w\t$m{$w}\n";$t+=$m{$w};}


sub seqcomp{
    my $o=shift;
    my $i=shift;
    my $o_n=shift;
    my $i_n=shift;
	my $length;
	my $lnoeg;
	my @tnote;
	my @t;
	my $length;
	my $per_sim;
	my $other_start;
	my $other_end;
	open(F1,">file1");
	open(F2,">file2");
	print F1">$o_n\n$o\n";
	print F2">$i_n\n$i\n";
	print "Aligning seq $o_n and seq $i_n with ";
	system("est2genome file1 file2 -outfile=file3");
	open(FN,"file3");
	while(my $line=<FN>){
		chomp $line;
		$lnoeg++;
		if(($lnoeg==1) and ($line=~/^Note/)){
			@tnote=split(/\s+/,$line);
		}
		if($line=~/^Span/){
			@t=split(/\s+/,$line);
			$length=@t[7]-@t[6]+1;
			$per_sim=@t[2]+0;
			$other_start=@t[3]+0;
			$other_end=@t[4]+0;
		}
	}
	close FN;
	close F1;
	close F2;
	return($per_sim,$length,$other_start,$other_end,@tnote[5]);
}


