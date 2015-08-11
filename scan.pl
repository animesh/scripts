#user/bin/perl

$word = 'TATA';
$count1= $count2 =0;
print "Enter the sequence file name\n";

$name = <>;
chomp ($name);

open (IN, $name);


while ($line = <IN>)
	{
	if ($line =~ /^>/)
		{
		$linename = $line;
		}
	else
		{
		push (@seq, $line);
		
		}
	}

foreach $el (@seq)
	{
#	print "$el\n";
	$len = length($el);
	$half = $len/2;
	$newstr1 = substr($el, 0, $half);
	push (@str1, $newstr1);
	print "1=$newstr1\n";
	$newstr2 = substr($el, $half, $len);
	print "2=$newstr2\n";
	push (@str2, $newstr2);
	}
#while ($num==4)
#{
for ($i=0; $i<=$#str1; $i++)
        {
print "$i............\n";
        $s1 = $str1[$i];
        $s2 = $str2[$i];
	#print "s1=$s1\ns2=$s2\n";
        $count1= $s1 =~ s/$word/$word/g;
        $count2= $s2 =~ s/$word/$word/g;
#print "$count1\n$count2\n\n";
$n=$i+1;
	if ($count1 == 0 and $count2 > 0)
		{
		 print "$word\tSeq#=$n,second\n";
                }
        elsif	($count1 > 0 and $count2 == 0)
		{               
                print "$word \t seq#=$n,first\n";
                }
        elsif ($count1 ==$count2)
                {
                print "$word can`t be grouped\n";
		}              
}                      
#}
