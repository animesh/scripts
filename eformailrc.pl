#!/usr/bin/perl
$f=shift @ARGV;
open(F,$f);

while($line=<F>){
	$c++;
	print "$line\t$c\n";
	if($c == 1){
		@namez=split(/\,/,$line);
	}
}
undef %saw;
@au = grep(!$saw{$_}++, @namez);

close F;

$fo=$f;
$fileemit=$fo.".emit";

open(FE,">$fileemit");

foreach $audi (@au){
	@temp=split(/\<|\>/,$audi);
	#for($c1=0;$c@temp) {
		
		if(@temp[1]=~/@/ and @temp[1]!~/\.$/){
			@temp[0]=~s/\"|\<|\>|\,|^\s+|\s+$|\.//g;
			@temp2=(split(/\s+/,@temp[0]));
			@temp2[0]=lc(@temp2[0]);
			#print FE"alias\t@temp2[0]\t\"@temp[0]\"\t@temp[1]\n";
			print FE"alias\t@temp2[0]\t@temp[1]\n";
		}
	#}
}

close FE;