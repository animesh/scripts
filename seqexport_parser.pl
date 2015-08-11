#!/usr/bin/perl

if( @ARGV ne 1){die "\nUSAGE\t\"ProgName MultSeqFile\t\n\n\n";}
$file = shift @ARGV;
open (F, $file) || die "can't open \"$file\": $!";
$seq="";
while ($line = <F>) {
	chomp $line;
	if ($line =~ /^>/){
		$c++;
		#$line=~s/\|/\-/g; $line=~s/\s+//g;#$line=substr($line,1,30);
		push(@seqname,$line);	
		if ($seq ne ""){
			push(@seq,$seq);
              		$seq = "";
            	}
      	}
	 else {$seq=$seq.$line;
      	}
}
push(@seq,$seq);
undef $c;
close F;

#for($c1=0;$c1<=$#seq;$c1++){
for($c1=0;$c1<1;$c1++){
	$fooo=$c1+1;
	$sname=@seqname[$c1];$sseq=uc(@seq[$c1]);
	@temps=split(//,$sseq);$N=length($sseq);
	for($c2=0;$c2<=$#temps;$c2++){
		if(@temps[$c2] ne "-"){
		$c3++;
		$seqmap{$c3}=$c2;
		print "$sname\t@temps[$c2]\t$c3\t$c2\n";
		$summa+=$c3;
		}
	}
	#print "Analysing\tseq no.$fooo\t$sname\t@temps[$seqmap{58}]\t@temps[102]\t@temps[195]\t$summa\t$N\n";
	undef %seqmap;undef $c3;undef $summa;
}
