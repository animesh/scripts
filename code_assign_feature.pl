$file1=shift @ARGV;
#$file2=shift @ARGV;
$ftr=shift @ARGV;
chomp $ftr;
#$file4="$file1.$ftr.$file2.csv";
open(F1,$file1);
#open(F2,$file2);
#open(F4,">$file4");
while(<F1>){
	$line++;
        chomp;
        @t=split(/,/);
	if($line==1){for($c=0;$c<=$#t;$c++){
		$label{@t[$c]}=$c;
	}}
	#else{
	$id=@t[$label{"ID"}];
	$fval=@t[$label{$ftr}];
	$cat{$id}=$fval;
	print "$line\t$id\t$cat{$id}\n";
	#}
}
$line=0;
$file2=shift @ARGV;
open(F2,$file2);
$fout="$file2.$file1.$ftr.csv";
$foutr11="$file2.$file1.$ftr.r1.t1.csv";
$foutr21="$file2.$file1.$ftr.r2.t1.csv";
$foutr31="$file2.$file1.$ftr.r3.t1.csv";
$foutr12="$file2.$file1.$ftr.r1.t2.csv";
$foutr22="$file2.$file1.$ftr.r2.t2.csv";
$foutr32="$file2.$file1.$ftr.r3.t2.csv";
$foutr13="$file2.$file1.$ftr.r1.t3.csv";
$foutr23="$file2.$file1.$ftr.r2.t3.csv";
$foutr33="$file2.$file1.$ftr.r3.t3.csv";
$foutr="$file2.$file1.$ftr.r";
open(FO,">$fout");
open(FOR11,">$foutr11");
open(FOR21,">$foutr21");
open(FOR31,">$foutr31");
open(FOR12,">$foutr12");
open(FOR22,">$foutr22");
open(FOR32,">$foutr32");
open(FOR13,">$foutr13");
open(FOR23,">$foutr23");
open(FOR33,">$foutr33");
open(FOR,">$foutr");
while($l=<F2>){
	$l=~s/^\s+//;
	$l=~s/\s+$//;
	@t=split(/\,/,$l);
	$line++;
	if($line==1){
			for($c=0;$c<=$#t-6;$c++){
				$cp=$c+1;
				print FO"V$cp,";
                                print FOR11"V$cp,";
                                print FOR21"V$cp,";
                                print FOR31"V$cp,";
                                print FOR12"V$cp,";
                                print FOR22"V$cp,";
                                print FOR32"V$cp,";
				print FOR13"V$cp,";
				print FOR23"V$cp,";
				print FOR33"V$cp,";
			}
			print FO"CLASS\n";
                        print FOR11"CLASS\n";
                        print FOR21"CLASS\n";
                        print FOR31"CLASS\n";
                        print FOR12"CLASS\n";
                        print FOR22"CLASS\n";
                        print FOR32"CLASS\n";
			print FOR13"CLASS\n";
			print FOR23"CLASS\n";
			print FOR33"CLASS\n";
	}
        $out0=@t[-6]+0;#svm_mat(:,11966) time
        $out1=@t[-5]+0;#svm_mat(:,11967) reps
        $out2=@t[-4]+0;#svm_mat(:,11968) ? 1 or 2
        $out3=@t[-3]+0;#svm_mat(:,11969) participants 9 or 10
        $out4=@t[-2]+0;#svm_mat(:,11970) code ?
        $out5=@t[-1]+0;#svm_mat(:,11971) code Turid?
	$out2=$cat{$out5};
	for($c=0;$c<=$#t-6;$c++){
		$out=@t[$c]+0;
		print FO"$out,";
                if($out0==1 && $out1==1){print FOR11"$out,";$cnt{"$c-$out3-$out4"}++;}
                if($out0==2 && $out1==1){print FOR21"$out,";$cnt{"$c-$out3-$out4"}++}
                if($out0==3 && $out1==1){print FOR31"$out,";$cnt{"$c-$out3-$out4"}++}
                if($out0==1 && $out1==2){print FOR12"$out,";$cnt{"$c-$out3-$out4"}++;}
                if($out0==2 && $out1==2){print FOR22"$out,";$cnt{"$c-$out3-$out4"}++}
                if($out0==3 && $out1==2){print FOR32"$out,";$cnt{"$c-$out3-$out4"}++}
 		if($out0==1 && $out1==3){print FOR13"$out,";$cnt{"$c-$out3-$out4"}++;}
		if($out0==2 && $out1==3){print FOR23"$out,";$cnt{"$c-$out3-$out4"}++}
		if($out0==3 && $out1==3){print FOR33"$out,";$cnt{"$c-$out3-$out4"}++}
	}
	$out=@t[$c]+0; #svm_mat(:,11966) 
	print FO"G$out2\n";
        if($out0==1 && $out1==1){print FOR11"G$out2\n";print FOR"$c-$out1-$out2-$out3-$out4\t";}
        if($out0==2 && $out1==1){print FOR21"G$out2\n";print FOR"$c-$out1-$out2-$out3-$out4\t";}
        if($out0==3 && $out1==1){print FOR31"G$out2\n";print FOR"$c-$out1-$out2-$out3-$out4\t";}
        if($out0==1 && $out1==2){print FOR12"G$out2\n";print FOR"$c-$out1-$out2-$out3-$out4\t";}
        if($out0==2 && $out1==2){print FOR22"G$out2\n";print FOR"$c-$out1-$out2-$out3-$out4\t";}
        if($out0==3 && $out1==2){print FOR32"G$out2\n";print FOR"$c-$out1-$out2-$out3-$out4\t";}
 	if($out0==1 && $out1==3){print FOR13"G$out2\n";print FOR"$c-$out1-$out2-$out3-$out4\t";}
	if($out0==2 && $out1==3){print FOR23"G$out2\n";print FOR"$c-$out1-$out2-$out3-$out4\t";}
	if($out0==3 && $out1==3){print FOR33"G$out2\n";print FOR"$c-$out1-$out2-$out3-$out4\t";}
	if($line%57==0){print FOR"\n";}
	print "$line $out\tT$out0\tR$out1\tC$out2\tP$out3\tID$out4\tIDT$out5\n";
}
close F2;

