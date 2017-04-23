#!/usr/bin/perl
$file1=shift @ARGV;
chomp $file1;
open F2,$file1;
$ftr=5;
$rown=0;
while($l=<F2>){
	$rule=0;$rulc=0;$rown++;
	@t=split(/\s+/,$l);#$len=(@t);
		for($c=2;$c<=($ftr*3+1);$c=$c+3){
			#print "$c\t@t[$c]\t";
			if($l=~/^Rule/ and @t[$c]!~/-/){
				if($rulc%1==0){$rule++;}
				if($rown%2==0){
				    $X1=(@t[$c]);
				    $X2=(@t[$c+2]);
				    print "$X1\t$X2\t";
				}
				else{
				    $X1=(@t[$c]);
				    $X2=(@t[$c+2]);
				    print "$X1\t$X2\t";
				}
				$rulc++;
			}
		}
	print "\n";
}
close F2;
#X1=X2(Max0-MinO)+Min
#Mean1=Mean2(Max0-MinO)+Min
#Std1=Std2(Max0-MinO)



#perl fileform5.pl top4_tr.txt 4 top4_train_n.txt top4m.txt > res4.txt
#
#perl fileform5.pl top5_tr.txt 5 top5_train_n.txt top5.txt > res5.txt
#
#perl fileform5.pl top4_tr.txt 4 top4_train_n.txt top4.txt > res4.txt
#
#perl fileform5.pl top4_tr.txt 4 top4_train_n.txt top4m.txt > res4m.txt
#
#perl fileform5.pl top4_tr.txt 4 top4_train_n.txt top4.txt > res4.txt
#
#perl fileform5.pl top4_tr.txt 4 top4_train_n.txt top4m.txt
