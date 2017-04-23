while(<>){if($_!~/^>/){chomp;$str.=$_;}}
print length($str),"\t";
$str=uc($str);
$length=4;
#$str=reverse($str);$str=~tr/ACGT/TGCA/;
while($str =~ /GATC/g)
                                                {
                                                $posi=pos($str);
						$subs=substr($str,$posi-$length,$length);
                                                $posi=($posi-($length))+1;
                                                push(@temp,$posi);
						print "$posi\t";
                                                }
print "\n";
