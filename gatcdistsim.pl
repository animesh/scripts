use strict;
my $leng=shift @ARGV;
my $length=4;
my $sample=100;
use Math::NumberCruncher;
my @base=qw/A T G C/;
for(my $len=0;$len<=$leng;$len+=$leng/$sample){
	my $lengen;
	my $str;
	my @temp;
	while($lengen<$len){
		$str.=$base[int(rand(4))];
		$lengen++;
	}
	print length($str),"\t";
	while($str =~ /GATC/g){
		my $posi=pos($str);
                $posi=($posi-($length))+1;
                push(@temp,$posi);
		#print "$posi\t";
        }
	my @dist;
	for(my $d=0;$d<$#temp;$d++){push(@dist,@temp[$d+1]-@temp[$d])}
	print Math::NumberCruncher::Mean(\@dist),"\t";
	print Math::NumberCruncher::Median(\@dist),"\t";
	print Math::NumberCruncher::Mode(\@dist),"\t";
	print "\n";
}

