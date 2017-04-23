#!/usr/bin/perl
#print "enter file name \n";
#$file=<>;
#chomp;
open F1,"xen";
while($l=<F1>)
{
if($l=~/^>/)
{$lname=$lname.$l;}
else{
chomp($l);

$length=length($l);
#print "$length\n";
$li=$li.$l;
}
}
@seq=split(//,$li);
$len=@seq;
#print "$len\n";
for($c=0;$c<$len;$c=$c+200000){
	for($cc=$c;$cc<$c+200500;$cc++){
		$s1=$s1.@seq[$cc];
					}
$c1=$c+1;
$cc1=$cc+1;
print "pfchr2 seq from $c1 to $cc1\n";
print "$s1\n";
$s1="";
}
