#!/usr/bin/perl
system("ls /user1/ -1>t1.txt");
open F1,"t1.txt";
while($l1=<F1>){
chomp $l1;
@t1=split(/\s+/,$l1);
#foreach  (@t1) {$c++;print "$c\t$_\n";}
$n1=@t1[0];
print "$n1\n";
system("ls /user1/$n1/ -1>t2.txt");
open F2,"t2.txt";
	while($l2=<F2>){
		chomp $l2;
		@t2=split(/\s+/,$l2);
		$n2=@t2[0];
		print "$n1\t$n2\n";
		system("finger $n2");
	}	
}

