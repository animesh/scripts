#!/usr/bin/perl
$testseq="atatatattt";
$k="atatat";
print "$testseq\n$k\n";
#if($testseq =~ /$k/g)
#{
	while($testseq =~ /$k/g)
		{
        $position=pos($testseq);
        #print "$position \n";
        #pos($testseq)=0;
        }
		#}
@test2=qw/w e r t/;
$t=\@test2;
#print "@$t\n";
for($c=0;$c<10;$c++)
{	@test1=qw/r t y u/;
	$test{$c}=@$t[0..(-2)];
}
foreach $w (keys %test) {
	print "$test{$w}\n";
}
#$len=length($testseq);
#$subs=substr($testseq,0,6);
#print "$subs\n$len\n";