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
print "enter name of multiple sequences containing file in FASTA format: \n(sequences must be of same length)--\t";
$file=<STDIN>;
chomp $file;
open (F,$file)||die "cant open  :$!";
print "\nENTER-\n(1)For Hamming Distance Matrix calculation enter \t[1]\n";
print "(2)For J-K Distance Matrix calculation enter     \t[2]\n";
print "(3)For Kimura Distance Matrix calculation enter  \t[3]\n\nOPTION to 
be USED\t";
$choice=<STDIN>;
chomp $choice;
$seq="";
open (FF,">tabb.txt");
while ($line = <F>)
{	$line=lc($line);
        chomp ($line);
        if ($line =~ /^>/)
        {
            $line =~ s/>//;
            push(@seqname,$line);
            if ($seq ne "")
            {
              push(@seq,$seq);
              $seq = "";
            }
        }
        else
        {
            $seq=$seq.$line;
        }
}
push(@seq,$seq);
$co1=@seq;
#print $co1;
#$choice=2;
if($choice eq 2)
{
for($c=0;$c<$co1;$c++)
{
	for($cc=0;$cc<$co1;$cc++)
	{	if($c eq $cc){$mism[$c][$cc]=0;}
		if(@seq[$c] eq @seq[$cc]){last;}
		else{#print "$c\t$cc\n";
			@seqc=split(//,@seq[$c]);
			@seqcc=split(//,@seq[$cc]);
			$co2=@seqc;$co3=@seqcc;
			if($co2 le $co3){$co2=$co3;}
			for($ccc=0;$ccc<$co2;$ccc++)
				{
				if(@seqc[$ccc] =~ /@seqcc[$ccc]/){$match++;}
				else{$mismatch++;}
				}
				#print "$match\t$mismatch\n";
				$mismatch=$mismatch/$co2;
				$mismatch=(-3/4)*(log(1-((4/3)*$mismatch)));
				$mism[$c][$cc]=$mismatch;
				$mism[$cc][$c]=$mismatch;
				#print "$match\t$mismatch\n";
				$match=0;$mismatch=0;
			}
	}
}
print FF"    $co1\n";
for($c=0;$c<$co1;$c++)
{
	print FF"@seqname[$c]\t   ";
	for($cc=0;$cc<$co1;$cc++)
	{
	$rounded=sprintf("%0.3f",$mism[$c][$cc]);
	#$rounded=$rounded*10;
	print FF"$rounded ";

	}
	print FF"\n";
}
}
if($choice eq 1)
{
for($c=0;$c<$co1;$c++)
{
	for($cc=0;$cc<$co1;$cc++)
	{	if($c eq $cc){$mism[$c][$cc]=0;}
		if(@seq[$c] eq @seq[$cc]){last;}
		else{#print "$c\t$cc\n";
			@seqc=split(//,@seq[$c]);
			@seqcc=split(//,@seq[$cc]);
			$co2=@seqc;$co3=@seqcc;
			if($co2 le $co3){$co2=$co3;}
			for($ccc=0;$ccc<$co2;$ccc++)
				{
				if(@seqc[$ccc] =~ /@seqcc[$ccc]/){$match++;}
				else{$mismatch++;}
				}
				$mismatch=$mismatch/$co2;
				$mism[$c][$cc]=$mismatch;
				$mism[$cc][$c]=$mismatch;
				#print "$match\t$mismatch\n";
				$match=0;$mismatch=0;
			}
	}
}
print FF"    $co1\n";
for($c=0;$c<$co1;$c++)
{
	print FF"@seqname[$c]\t   ";
	for($cc=0;$cc<$co1;$cc++)
	{
	$rounded=sprintf("%0.3f",$mism[$c][$cc]);
	#$rounded=$rounded*10;
	print FF"$rounded ";

	}
	print FF"\n";
}
}
if($choice eq 3)
{
for($c=0;$c<$co1;$c++)
{
	for($cc=0;$cc<$co1;$cc++)
	{	if($c eq $cc){$mism[$c][$cc]=0;}
		if(@seq[$c] eq @seq[$cc]){last;}
		else{#print "$c\t$cc\n";
			@seqc=split(//,@seq[$c]);
			@seqcc=split(//,@seq[$cc]);
			$co2=@seqc;$co3=@seqcc;
			if($co2 le $co3){$co2=$co3;}
			for($ccc=0;$ccc<$co2;$ccc++)
				{
				if(@seqc[$ccc] =~ /@seqcc[$ccc]/){$match++;}
				elsif(((@seqc[$ccc] eq 'a') and (@seqcc[$ccc] eq 'g')) or ((@seqc[$ccc] eq 'g') and (@seqcc[$ccc] eq 'a')))
				{
					$ts++;
				}
				elsif(((@seqc[$ccc] eq 'c') and (@seqcc[$ccc] eq 't')) or ((@seqc[$ccc] eq 't') and (@seqcc[$ccc] eq 'c')))
				{
					$ts++;
				}
				else{$tv++}
				}
				#print "M-$match\tTS-$ts\tTV-$tv\t$match\n";
				$ts=$ts/$co2;$tv=$tv/$co2;
				$mismatch=(-1/2)*log((1-2*$ts-$tv)*((1-2*$tv)**(1/2)));
				$mism[$c][$cc]=$mismatch;
				$mism[$cc][$c]=$mismatch;
				#print "$match\t$mismatch\n";
				$match=0;$mismatch=0;$ts=0;$tv=0;
			}
	}
}
print FF"    $co1\n";
for($c=0;$c<$co1;$c++)
{
	print FF"@seqname[$c]\t   ";
	for($cc=0;$cc<$co1;$cc++)
	{
	$rounded=sprintf("%0.3f",$mism[$c][$cc]);
	#$rounded=$rounded*10;
	print FF"$rounded ";

	}
	print FF"\n";
}
}
print "    $co1\n";
for($c=0;$c<$co1;$c++)
{
	print "@seqname[$c]\t   ";
	for($cc=0;$cc<$co1;$cc++)
	{
	$rounded=sprintf("%0.3f",$mism[$c][$cc]);
	#$rounded=$rounded*10;
	print "$rounded ";

	}
	print "\n";
system "./neighbor";
system "clear";
print "The NJ tree has been saved in \" outfile \" and distance matrix in \"tabb.txt\"\n";}
