#!/usr/bin/perl
open f1,"tab.txt" || die "cant open";
$lc=0;
while($line=<f1>)
{
chomp $line;
push(@seq,$line);
}
$lc=@seq;
#rint $lc;
for($lii=0;$lii<$lc;$lii++){$li=@seq[$lii];
$li =~ s/\s+/\t/g;
$li =~ s/\t//;
@elem=split(/\t/,$li);
$len=@elem;
	for ($cc=0;$cc<$len;$cc++)
	{$tree[$lii][$cc]=@elem[$cc];
	}

}
#print "$tree[0][5]\t";
$row=1;$col=1;
$min=$tree[0][1];
for($lii=0;$lii<$lc;$lii++){#print "\n";
	for ($cc=0;$cc<$len;$cc++)
	{
                if($tree[$lii][$cc] ne "0" and $tree[$lii][$cc] <= $min){
                $min=$tree[$lii][$cc];$row=($lii+1);$col=($cc+1);
                }
	}

}
print "$row\t$col\n$min\n";