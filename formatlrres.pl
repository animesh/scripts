$filetemplr = shift @ARGV;
chomp $filetemplr;
system("grep -E \"a = C0\|b = C1\" IC_*_toML.txt.class.arff.10fold.lr.txt > $filetemplr ");
open(F,$filetemplr);
$filetemplrout=$filetemplr.".out";
open(FO,">$filetemplrout");
while(<F>){
	chomp;
	$c++;
	print "$c\n";
	@t1=split(/\s+/);
	if($c%4==1){
		@t2=split(/\./,@t1[0]);
		print FO"@t2[0],";
	}
	print FO"@t1[1],@t1[2],";
	if($c%4==0){print FO"\n";}
}




__END__
 1266  md5sum IC_??.txt.ru.class.arff.lrclass.txt | awk '{print $1}' | sort | uniq
 1267  md5sum IC_??.txt.ru.class.arff.lrclass.txt | awk '{print $1}' | sort | uniq | wc
 1268  wc IC_??.txt.ru.class.arff.lrclass.txt | wc
 1269  cp IC_??.txt.ru.class.arff.lrclass.txt lr/.
 1270  cd lr
 1271  wc IC_??.txt.ru.class.arff.lrclass.txt 
 1272  wc IC_??.txt.ru.class.arff.lrclass.txt | less
 1273  ls
 1274  grep -E "a = C0|b = C1" IC_?.txt.ru.class.arff.lrclass.txt 
 1275  grep -E "a = C0|b = C1" IC_?.txt.ru.class.arff.lrclass.txt >> result.txt
 1276  grep -E "a = C0|b = C1" IC_??.txt.ru.class.arff.lrclass.txt >> result.txt

