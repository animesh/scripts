#!/usr/bin/perl
#programme for motif generation FASTER ALGO;
@base=qw/a t c g/;
#print "\nenter the multiple seq. containing fasta file name\t:";
$file="ys.txt";
#$file=<>;
#chomp $file;
open(F,$file)||die "can't open";
#print "\nenter the output filename for position matrix\t:";
$dout="anid.txt";
#$dout=<>;
#chomp $dout;
#print "\nenter the output filename for -number of occurence- matrix\t:";
$out="anip.txt";
#$out=<>;
#chomp $out;
#print "\nenter the filename for the R matrix\t:";
$rmatixfile="anir.txt";
#$rmatixfile=<>;
#print "\nenter the length of motif\t:";
#$colo=<>;
#chomp $colo;
$out="co.txt";

$colo=4;
$colothresh=5;
$seq = "";

while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\t/,$line);
		$snames=@seqn[0];
		chomp $snames;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
print "$file file read\n";
push(@seq,$seq);$tots2=@seqname;close F;
$plan[0][0]=0;
$dist[0][0]=0;

while($colo<$colothresh){
for($x11=0;$x11<$tots2;$x11++){$sname=@seqname[$x11];
chomp $sname;
$sname =~ s/\>//g;
$d9=$x11+1;$plan[0][$d9]=$sname;$dist[0][$d9]=$sname;
chomp $testseq;
$testseq=lc(@seq[$x11]);
$len=length($testseq);
#print "$sname\n$testseq\n";
for($co2=0;$co2<=($len-$colo);$co2++)
	{$subs=substr($testseq,$co2,$colo);
	chomp $subs;
	push(@fran,$subs);
	$co2n=$co2+1;
	push (@{$posito{$subs}},$co2n);
	}
%seen=();
@uniq = grep{ !$seen{$_} ++} @fran;
$tots3=@uniq;
#foreach  (@uniq) {print "$_\t";}
foreach $cc (@uniq)
   {$cont=$posito{$subs};
   $sl=length($cc);
	if($cont ne "" and $sl eq $colo){$treehash{$cc}=$cont;#print "$cc\t$cont\n";
					}
	}
for($d6=1;$d6<=$tots3;$d6++)
	{$d7=$d6-1;$plan[$d6][0]=@uniq[$d7];$dist[$d6][0]=@uniq[$d7];
	}
for($d4=1;$d4<=$tots3;$d4++)
		{foreach $d5 (keys %treehash) {$d7=$x11+1;
			if($plan[$d4][0] eq $d5){$plan[$d4][$d7]=@{$posito{$d5}};$dist[$d4][$d7]="@{$posito{$d5}}";#print @{$posito{$d5}};
			}
			}
		}
undef %treehash;
undef %posito;
}
$comp=0;
for($d3=0;$d3<=$tots3;$d3++){
for($d2=0;$d2<=$tots2;$d2++){
                if($plan[$d3+1][$d2+1] ne ""){$comp++ ;
                                         }
        }if($comp ge 1){$thresh{$plan[$d3+1][0]}=$comp;}
        $comp=0;
}
#combos();
$colo++;
print "Analysing $colo read\n";
}
open (FD,">$dout");
open (FO,">$out");
print FO"\t";
print FD"\t";
for($d2=1;$d2<=$tots2;$d2++){print FD"$dist[0][$d2]\t";}print FD"\n";
for($d2=1;$d2<=$tots2;$d2++){print FO"$plan[0][$d2]\t";}print FO"\n";
foreach $uu (sort {$thresh{$b} <=> $thresh{$a}} keys %thresh){
$tots3=@uniq;
$tots2=@seqname;
print FO"$uu\t";
print FD"$uu\t";
for($d3=1;$d3<=$tots3;$d3++){
for($d2=1;$d2<=$tots2;$d2++){
if($plan[$d3][0] eq $uu) {print FO"$plan[$d3][$d2]\t";#print "calc #no. matrix$d3.$d2\n";
}
}if($plan[$d3][0] eq $uu) {print FO"$thresh{$uu}\n";}
}
for($d3=1;$d3<=$tots3;$d3++){
for($d2=1;$d2<=$tots2;$d2++){
if($plan[$d3][0] eq $uu) {print FD"$dist[$d3][$d2]\t";#print "calc dist matrix$d3.$d2\n";
}
}if($plan[$d3][0] eq $uu) {print FD"$thresh{$uu}\n";}
}
}
close F;close FO;close FD;
for($d3=1;$d3<=$tots3;$d3++){
for($d2=1;$d2<=$tots2;$d2++){
$plan[$d3][$d2]=0;
}
}
@combos=@uniq;
$tots2=@seqname;
$plan[0][0]=0;$cont=0;	
for($c1=0;$c1<=$#combos;$c1++){$r1=@combos[$c1];for($c2=0;$c2<=$#combos;$c2++){
	$r2=@combos[$c2];
if($r1 ne $r2){$cont++;
for($x11=0;$x11<$tots2;$x11++){$sname=@seqname[$x11];
		chomp $sname;
		$sname =~ s/\>//g;
		@tr=split(/ /,$sname);
		$sname=@tr[0];$plan[0][($x11+1)]=$sname;
		#print "$sname\t";
		$testseq=lc(@seq[$x11]);
		$cor1=$testseq =~ s/$r1/$r1/g;
		$cor2=$testseq =~ s/$r2/$r2/g;
			if(($cor1 > 0 and $cor2 > 0) and ($cor1 < 4 and $cor2 < 4)){$comm++;
$plan[$cont][(0)]="$r1 and $r2";
$plan[$cont][($x11+1)]=1;
#print "$r1\-$r2\*$cor1\-$cor2\t";	
				}#else{$plan[$cont][($x11+1)]="$cor1 and $cor2";}
			}$desc{"$r1 and $r2"}=$comm;$comm=0;	#else{$cont;}						
	}else{#$plan[$cont][($x11+1)]="none";
		last;}
}
#print "\n";
}
open (FO,">$out");

$contis=$cont+1;
$tots3=$contis;
for($d2=0;$d2<=$tots2;$d2++){
print FO"$plan[0][$d2]\t";}print FO"\n";
foreach $eu (sort {$desc{$b} <=> $desc{$a}} keys %desc){
for($d3=0;$d3<=($contis);$d3++){for($d2=0;$d2<=$tots2;$d2++){
if($plan[$d3][0] eq $eu) {print FO"$plan[$d3][$d2]\t";}
}
if($plan[$d3][0] eq $eu) {print FO"$desc{$eu}\n";}
}
}
close FO;

open (FG,">$rmatixfile");
for($d2=1;$d2<=$tots2;$d2++){
for($d3=1;$d3<=$tots3;$d3++){
$m+=$plan[$d3][$d2];
}$name=$plan[0][$d2];$mean{$name}=($m/($d3-1));
$m=0;
}
for($d2=1;$d2<=$tots2;$d2++){$name=$plan[0][$d2];
for($d3=1;$d3<=$tots3;$d3++){
$m11+=(($plan[$d3][$d2]-$mean{$name})**2);
#print "$plan[$d3][$d2]\t";
}$sd{$name}=sqrt($m11/($d3-1));
#print "$d3\t$m11\n";
$m11=0;
}			for($d22=1;$d22<=$tots2;$d22++){$n1=$plan[0][$d22];
				for($d2=1;$d2<=$tots2;$d2++){$n2=$plan[0][$d2];#print "seq1=>$n1\tseq2=>$n2\n";
					if($n1 eq $n2){$rmatix[$d22][$d2]=0;$rmatixn[$d22][$d2]=0;
					}
					else{for($d3=1;$d3<=$tots3;$d3++){
							$nnn+=(($plan[$d3][$d22]-$mean{$n1})*($plan[$d3][$d2]-$mean{$n2})/($sd{$n1}*$sd{$n2}));
$nnnn=((($plan[$d3][$d22]-$mean{$n1})*($plan[$d3][$d2]-$mean{$n2})/($sd{$n1}*$sd{$n2}))/($tots3));
							}$nnn=($nnn/($d3-1));$rmatix[$d22][$d2]=$nnn;$rmatix[$d2][$d22]=$nnn;
							$rmatixn[$d22][$d2]=((1-$nnn)/2);$rmatixn[$d2][$d22]=((1-$nnn)/2);
							$nnn=0;
						}
				}
			}
print FG"$tots2\n";
for($d4=1;$d4<=$tots2;$d4++){print FG"@seqname[($d4-1)]\t";
for($d5=1;$d5<=$tots2;$d5++){
print FG"$rmatixn[$d4][$d5]\t";}
print FG"\n";
}close FG;

system "aninj.exe";
system "write aninj.txt";
system "aniupgma.exe";
system "write aniupgma.txt";
#sub combos {
#}