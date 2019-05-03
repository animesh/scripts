#!/usr/bin/perl
print "File containing sequence names? ";
chomp ($file = <STDIN>);
open (FILEIN,"$file");
open(FILEOUT,">blastn");
while (chomp ($seq = <FILEIN>) )
{$sout=$seq.".html";
print FILEOUT"/home/andrew/bic/blastcl3 -p blastn -d nr -i $seq -o $sout -T\n";
}


#!/usr/bin/perl
#parse blast results
$count=0;
print "the blast file name \n";
$_=<>;
chomp;
open (o,"$_")|| die;
$line=<o>;
chomp $line;
while ($line=<o>)
{
push (@file,$line);
}
for ($i=0;$i<=$#file;$i++)
{
$line=$file[$i];
chomp$line;
$full="";
if ($line=~/Query=/)
{               $i++;
                $full=$line.$file[$i++];
                chomp $full;
	push (@exon,$full);
	while($count==0){
	$i++;
	$line1=$file[$i];
                chomp$line1;
	if ($line1=~/Sequences/)
	{               #print "found";
		$i=$i+2;
		$line2=$file[$i];
                                chomp$line2;
		push (@hit,$line2);
		$count=1;
	}
	elsif($line1=~/No/)
	{
		push (@hit,$line1);
		$count=1;
	}
                }
	$count=0;
}

}
$num=0;
foreach $exon(@exon)
{
print "$exon:$hit[$num]\n";
$num++;}

#!/usr/bin/perl
use strict;
my $main_file_pattern=shift @ARGV;chomp $main_file_pattern;
open(F,$main_file_pattern)||die "can't open";
my ($w,$c,$line,$snames,@seqname,@seq,$fresall,$seq,$seqname,%match2,%match3,%match4,%matchl1,%matchl2);
while ($line = <F>) {
        chomp ($line);
	my @temp=split(/\t/,$line);
	for($c=0;$c<=$#temp;$c++){
        if (@temp[$c] =~ /region of query/){
		my @temp2=split(/\s+/,@temp[$c]);
	        my $l1=@temp2[2]-@temp2[0];
		my $l2=@temp2[9]-@temp2[7];
		if(@temp2[0]!=@temp2[7] && @temp2[2]!=@temp2[9] && $l1>20 && $l2>20){
		#print "@temp2[0]\t@temp2[2]\t@temp2[7]\t@temp2[9]\t$l1\t$l2\n";
		$match2{@temp2[0]}=@temp2[2];
		$match3{@temp2[0]}=@temp2[7];
                $match4{@temp2[0]}=@temp2[9];
                $matchl1{@temp2[0]}=$l1;
		$matchl2{@temp2[0]}=$l2;
		}
            }
        else {
	#$seq=$seq.$line;
        }
	}
}

foreach $w (sort {$a<=>$b} keys %match2) {
	if($w<$match3{$w} && ($matchl1{$w}/$matchl2{$w}>0.9 || $matchl1{$w}/$matchl2{$w}<1.1)){
		print "$w - $match2{$w}\t$match3{$w} - $match4{$w}\t$matchl1{$w}\t$matchl2{$w}\n";
	}
}



#!/usr/bin/perl
while(<>){chomp;split(/\s+/);$c++;$dictast{length(@_[0])}.=">s.$c\n@_[0]\n";}
foreach $w (sort {$b<=>$a} keys %dictast){
	open(FI,">temp.blast.in");
	print "Blasting $w length word(s) file\n";
	print FI"$dictast{$w}";
	close FI;
	#system("cp 1T32.A.fas temp.blast.in");
	system("blastcl3 -p blastp -d swissprot -i temp.blast.in -o temp.blast.out");
	open(FO,"temp.blast.out");
	my $c=0; 
	while(<FO>){
		print $_;
		if($_=~/^Sequences producing significant/){
			close FO;	
			die;
		}
	}
}


