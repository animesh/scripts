print "SNNS pattern definition file V3.2\n";
print "generated at Thu Sep 30 15:58:23 2010\n\n\n";
$num=shift @ARGV;
$ni=6;
$no=11;
chomp $num;
@base=qw/-1 0 1/;
print "No. of patterns : $num\n";
print "No. of input units : $ni\n";
print "No. of output units : $no\n\n";
$numc=1;
while($numc<=$num){
	print "#Input pattern $numc\n";
	for($c=0;$c<$ni;$c++){push(@tmp,@base[int(rand(3))])}	
	print join(" ",@tmp),"\n";
	undef @tmp;
	print "#Output pattern $numc\n";
	for($c=0;$c<$no;$c++){push(@tmp,@base[int(rand(3))])}	
	print join(" ",@tmp),"\n";
	undef @tmp;
	$numc++;
}
