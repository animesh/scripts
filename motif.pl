#!/usr/bin/perl
$f=shift @ARGV;
open (F,$f);
print $f;
open (FO,">$f.motif.txt");

#readelm();
sub readelm{
	while ($line = <F>) {
			chomp ($line);
			$line=~s/\r//g;
			@se=split(/\t/,$line);
			$snames="@se[0]-@se[2]-@se[3]";
			push(@seqname,$snames);
			push(@seq,uc(@se[1]));
	}
	$tots2=@seqname;close F;
}


readfasta();
sub readfasta{
	while ($line = <F>) {
			chomp ($line);
			if ($line =~ /^>/){
				 @seqn=split(/\t/,$line);
			$snames=@seqn[0];
			chomp $snames;
				 push(@seqname,$snames);
					if ($seq ne ""){
				  push(@seq,uc($seq));
				  $seq = "";
				}
		  } else {$seq=$seq.$line;
		  }
	}
	push(@seq,$seq);$tots2=@seqname;close F;
}

print FO"SeqName\tPosition(s)\tMotif(s)\n";
#$motif=tgastcw;
#@to=split(//,$motif);
#for($c=0;$c<=$#to;$c++)
#{if(@to[$c] eq ( a or g or t or c ){$l=$l.@to[$c];}
#elsif(@to[$c] eq s){$l1=$l.g;$l2=$l.c;}
#elsif(@to[$c] eq w){$l3=$l.a;$l4=$l.t;}
#elsif(@to[$c] eq y){$l.=t;$l.=c;}
#elsif(@to[$c] eq p){$l.=g;$l.=a;}
#}
#push(
#$motif1=$motif;
#$motif1 =~ s/s/g/g;push(@gcnp,$motif1);
#$motif1=$motif;
#$motif1 =~ s/s/g/g;push(@gcnp,$motif1);
#@gcnp=qw/M..[LIV]..QQ/;
@gcnp=qw/K.[MILV]..[FY][FY] QK.[MILV]..[FY][FY] Q..[MILV]..[FY][FY]/;
#QK.[MILV]..[FY][FY]
#Q..[MILV]..[FY][FY]
for($c=0;$c<$tots2;$c++)
{
#tgastcw
#for($x5=0,$x6=1,$x7=2,$x8=3,$x9=4,$x10=5,$x11=6;$x10<$t1;$x5=$x5+1,$x6=$x6+1,$x7=$x7+1,$x8=$x8+1,$x9=$x9+1,$x10=$x10+1,$x11=$x11+1)
#	{#print $x21;
#	$x21=@elem[$x5].@elem[$x6].@elem[$x7].@elem[$x8].@elem[$x9].@elem[$x10].@elem[$x11];
#	push(@seqcod,$x21);#print "$x21\n";
#	}
$testseq=(@seq[$c]);
foreach $tt (@gcnp) {$length=length($tt);
while($testseq =~ /$tt/g)
						{
						$posi=pos($testseq);
						$posi=($posi-($length+1));
						push(@temp,$posi);
						push(@tempm,$tt);
						}
	}
print FO"@seqname[$c]\t",join(',',@temp),"\t",join(',',@tempm),"\n";
print "@seqname[$c]\t@temp\n";
undef @temp;
undef @tempm;
}

__END__

for i in /cygdrive/l/Results/Ani/cplm_download/*.elm ; do perl motif.pl $i ; done