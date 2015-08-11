$timdif=td("01:23:57","01:12:28");#print "$timdif\n";
while(<>){$l++;$s=$_;$s=~s/\s+//g;if($_!~/[A-Z]/i and $_!~/:/ and $s ne ""){push(@n,$_);$cnt=$_;}elsif($_=~/:/){push(@t,$_);}else{$d{$cnt+0}.=$_;}}
for($c=0;$c<=$#t;$c++){
if($c<670){$dn=$n[$c]+0;print $dn,"\n",$t[$dn],$d{$dn};}
elsif($c>794&&$c<1221){
	$dn=$n[$c]-125;
	$tf1=$t[$dn];
	$tf2=$t[$c];
	@t1=split(/,|\s+/,$tf1);
	@t2=split(/,|\s+/,$tf2);
	$tr1=td($t2[0],$timdif);
	$tr2=td($t2[3],$timdif);
	#print "$t2[0]\t$t2[3]\t$tr1\t$tr2\n";
	print $dn,"\n","$tr1,$t2[1] $t2[2] $tr2,$t2[4]\n",$d{$c+1};
}
else{next}
}

#source http://www.tek-tips.com/viewthread.cfm?qid=1169036
sub td {
my $time1 = shift;
my $time2 = shift;
my @time1 = split /:/, $time1, 3;
my @time2 = split /:/, $time2, 3;

my $secs1 = $time1[0] *3600 + $time1[1] *60 + $time1[2];
my $secs2 = $time2[0] *3600 + $time2[1] *60 + $time2[2];

my $result = $secs1 - $secs2;

my @result = (int($result /3600), int($result /60) %60, $result %60);
return sprintf("%02d:%02d:%02d", @result);
}

