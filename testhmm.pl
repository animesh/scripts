#!/usr/bin/perl
if(@ARGV != 4){print "usage:\tprogname c nc mm-model test\n";die;}
@base=qw/a t c g/;$bc=@base;
$file1=shift @ARGV;
$file2=shift @ARGV;
$co=shift @ARGV;$colo=$co+1;$jump=1;
$file3=shift @ARGV;
$total=$bc**$colo;#print $total;

(@sq1)=openfile($file1);undef @seqname;#print "sn\t\tsq @sq1\n";
(@sq2)=openfile($file2);undef @seqname;#print "sn\t\tsq @sq2\n";

%mash1=createhash(@sq1);
undef @sq1;undef %mash;
%mash2=createhash(@sq2);
undef @sq2;undef %mash;
#%mash11=formathash(\%mash1);

foreach $k (keys %mash1) {
	for($b2=0;$b2<=$#base;$b2++)
	{$su2=substr($k,0,$co);
	$su22=@base[$b2];
	$su222=$su2.$su22;
		if($mash1{$su222} eq ""){
		$mash1{$su222}=1;#print "$k => $mash1{$su222}\n";#print "$k => $mash2{$k}\n";
		}
	}
}
foreach $k (values %mash1) {$cash1+=$k;}
foreach $k (keys %mash1) {$mash1{$k}=$mash1{$k}/$cash1;1/1;}

foreach $k (keys %mash2) {
	for($b2=0;$b2<=$#base;$b2++)
	{$su2=substr($k,0,$co);
	$su22=@base[$b2];
	$su222=$su2.$su22;
		if($mash2{$su222} eq ""){
		$mash2{$su222}=1;#print "$k => $mash1{$su222}\n";#print "$k => $mash2{$k}\n";
		}
	}
}
foreach $k (values %mash2) {$cash2+=$k;}
foreach $k (keys %mash2) {$mash2{$k}=$mash2{$k}/$cash2;1/1;}

(@sq3)=openfile($file3);
$fooo1=$file3."\.pP.out";$fooo2=$file."\.pN.out";$fooo3=$file."\.p0.out";
open FC1,">$fooo1";open FC2,">$fooo2";open FC3,">$fooo3";
for($fot=0;$fot<=$#sq3;$fot++){
$seq=lc(@sq3[$fot]);$seqname=@seqname[$fot];$len=length($seq);
		for($cot=0;$cot<=($len-$colo);$cot++)
			{$subs=substr($seq,$cot,$colo);
			if(($mash2{$subs} ne "") and ($mash1{$subs} ne ""))
				{$p=$mash1{$subs}/$mash2{$subs};1/1;
				$prob+=log($p);}
			elsif(($mash2{$subs} eq "") and ($mash1{$subs} eq ""))
				{$p=$cash2/$cash1;1/1;
				$prob+=log($p);}
			elsif($mash2{$subs} eq "")
				{$p=$mash1{$subs}/(1/$cash2);#print "$p\n";
				$prob+=log($p);}
			elsif($mash1{$subs} eq "")
				{$p=(1/$cash1)/$mash2{$subs};
				$prob+=log($p);}
			}
$seq=uc(@sq3[$fot]);
if($prob gt 0){
print "coding\t$seqname\t$prob\n";
print FC1">$seqname\tP-$prob\n$seq\n";
}
elsif($prob eq 0){
print "fifty-fifty !\t$seqname\t$prob\n";
print FC3">$seqname\tP-$prob\n$seq\n";
}
else{
print "non-coding\t$seqname\t$prob\n";
print FC2">$seqname\tP-$prob\n$seq\n";
}
$prob=0;
}
close FC1;close FC2;close FC3;
undef @sq3;
sub openfile {
$file=shift;undef @seqname;undef @seq;
$seq="";
open(F,$file)||die "can't open";
while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\t/,$line);
		#$snames=@seqn[0];
		$snames=$line;
		chomp $snames;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}push(@seq,$seq);return (@seq);close F;
}

sub createhash{
	@seq=@_;
	for($x11=0;$x11<=$#seq;$x11++){
		$seq=lc(@seq[$x11]);chomp $seq;
		$len=length($seq);
		for($co2=0;$co2<=($len-$colo);$co2++)
			{$subs=substr($seq,$co2,$colo);
			#push(@fran,$subs);
			$mash{$subs}+=1;
			}
	}
return %mash;undef %mash;
}#foreach $k (keys %mash) {print "$k => $mash{$k}\n";}
