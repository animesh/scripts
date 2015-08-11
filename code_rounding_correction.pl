$file1=shift @ARGV;
$file2=shift @ARGV;
$file3=shift @ARGV;
$file4=shift @ARGV;
open(F1,$file1);
open(F2,$file2);
open(F3,$file3);
open(F4,$file4);
while(<F2>){
	chomp;
	@t=split(/,/);
	#print "@t[0]\n";
	$r=@t[0];
	$r=~s/\s+//g;
	if($r=~/^[0-9]/){$d1{$r}="D1-@t[5],D1-@t[6],D1-@t[7],D1-@t[8],D1-@t[9],D1-@t[10],D1-@t[11]";}
	#print "$r\t$_\n";
}
while(<F3>){
        chomp;
        @t=split(/,/);
        #print "@t[0]\n";
        $r=@t[0];
        $r=~s/\s+//g;
        if($r=~/^[0-9]/){$d2{$r}="@t[6],@t[7],@t[8],@t[9],@t[10],@t[11],@t[12],@t[13],@t[14],@t[17],@t[20],@t[23],@t[26]";}
#        print "$r\t$d2{$r}\n";
}
while(<F4>){
        chomp;
        @t=split(/,/);
        #print "@t[0]\n";
        $r=@t[0];
        $r=~s/\s+//g;
 	@t1=split(/-/,$r);
	$r=@t1[1];
        if($r=~/^[0-9]/){$d3{$r}="D3-@t[1],D3-@t[2],D3-@t[7]";}
        #print "$r\t$d3{$r}\n";
}

print "ID,ID0,Task,Repetition,Group,Participant,CodeG,CodeT,CodeK,RIdxCat11,Type11,Litracy11,Gender11,Genetics11,Handedness11,TrainingT11,RiskIdx,RIdxCat,Type,Litracy,Gender,Genetics,Handedness,TrainingT,EA5,EA6,EA7,EA8,EA11,RIdxCat5,Type5,CodeS\n";
%codess=(112100=>'112105',
231100=>'231101',
231280=>'231283',
232180=>'232180',
242180=>'242184',
351290=>'351293',
352140=>'352140',
361240=>'361243',
361280=>'361278',
362200=>'362204',
362260=>'362258',
362290=>'362288',
471200=>'471177',
472210=>'472206',
472260=>'472256',
481160=>'481163',
482220=>'482219',
491140=>'491144',
492150=>'492146',
);
#foreach (keys %codess) {print "$_ $codess{$_}\n";}
while(<F1>){
        chomp;
        @t=split(/,/);
        $r=@t[-1]; 
	$r+=0;;
	$o=$r;
	$r=$codess{$r};
        if($d1{$r} or $d2{$r} or $d3{$r}){print "$o,$r,$_,$d1{$r},$d2{$r},$d3{$r}\n";}
	else{print "$o,$r,$_,NO-DATA-AVAILABLE\n"}
}

