#!/usr/bin/perl
$th=0.99;
$fcovmat=shift @ARGV;
open(FCM,"$fcovmat");
while($l=<FCM>){
	chomp $l;
	push(@fcm,$l);
}
close FCM;
$fo=$fcovmat."pos.out";
open(FO,">$fo");
for($c1=0;$c1<=$#fcm;$c1++){
	@t=split(/\t/,@fcm[$c1]);
	for($c2=$c1+1;$c2<=$#t;$c2++){
		if((@t[$c2]<-($th)||@t[$c2]>($th))&&@t[$c2]!=-1&&@t[$c2]!=1&&@t[$c2] ne "NA"){
		#if((@t[$c2]<-($th)||@t[$c2]>($th))&&@t[$c2] ne "NA"){
			print FO "Pos",$c1+1,"-", "Pos", $c2+1 ," ~ ", sprintf("%.3f",@t[$c2]),"\n";
		}
	}
	@fcm[$c1]=~s/\s+//g;
	chomp @fcm[$c1];
	if(@fcm[$c1] ne ""){
		#print FO"\n";
	}
}
close FO;
