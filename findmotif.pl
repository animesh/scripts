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
if( @ARGV ne 2){die "\nUSAGE\t\"ProgName MultSeqFile1 MultSeqFile2\t\n\n\n";}
$file = shift @ARGV;
open (F, $file) || die "can't open \"$file\": $!";
$seq="";
while ($line = <F>) {
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		#print "Reading\t\tseq no.$c\t$line\n";
		#$line=~s/\|/\-/g; $line=~s/\s+//g;#$line=substr($line,1,30);
		push(@seqname,$line);	
		#@seqn=split(/\s+/,$line);push(@seqname,$seqn[0]);#$snames=$line;
		if ($seq ne ""){
			push(@seq,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seq,$seq);
close F;
$file1=$file;


$file = shift @ARGV;
open (F, $file) || die "can't open \"$file\": $!";
$seq="";$c=0;
while ($line = <F>) {
	if ($line =~ /^>/){
		$c++;
		chomp $line;
		#print "Reading\t\tseq no.$c\t$line\n";
		#$line=~s/\|/\-/g; $line=~s/\s+//g;#$line=substr($line,1,30);
		push(@oseqname,$line);	
		#@seqn=split(/\s+/,$line);push(@seqname,$seqn[0]);#$snames=$line;
		if ($seq ne ""){
			push(@oseq,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@oseq,$seq);
close F;
$file2=$file;

#@t=split(/\./,$file1);
#$file1=@t[0];
#@t=split(/\./,$file2);
#$file2=@t[0];

$fo=$file1.".".$file2.".ac.out";

for($c1=0;$c1<=$#seq;$c1++){
    alignace($seq[$c1],$oseq[$c1],$seqname[$c1],$oseqname[$c1]);
    print "LENGTH",length($seq[$c1]),"\n";
}


sub alignace{
    my $o=shift;
    my $i=shift;
    my $seq_o_name=shift;
    my $seq_i_name=shift;
    my $seq_o=$o;
    my $seq_i=$i;
    my $seq_o_length=length($o);
    my $seq_i_length=length($i);

    open(F1,">file1");
    print F1">$seq_o_name\n$seq_o\n";
    print F1">$seq_i_name\n$seq_i\n";
    print "Finding common motif in seq $seq_i_name and seq $seq_o_name with alignace";
    system("alignace -i file1 >> $fo");
    close F1;
}
