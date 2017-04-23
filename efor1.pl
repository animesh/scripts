#!/usr/bin/perl
$f=shift @ARGV;
open(F,$f);

while($line=<F>){
	$c++;
	print "$line\t$c\n";
	if($c == 1){
		@namez=split(/\s+/,$line);
	}
}
undef %saw;
@au = grep(!$saw{$_}++, @namez);

close F;

$fo=$f;
$fileemit=$fo.".emit";

open(FE,">$fileemit");

foreach $name (@namez){
	if($name=~/@/ and $name!~/\.$/){
		$name=~s/\<|\>|\,//g;
		print FE"$name, ";
	}
}

close FE;