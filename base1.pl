#!/usr/bin/perl
#programme for motif generation FASTER ALGO;
@base=qw/a t c g/;
#print "\nenter the multiple seq. containing fasta file name\t:";
$file="ys.txt";
#$file=<>;
#chomp $file;
open(F,$file)||die "can't open";
#print "\nenter the output filename for position matrix\t:";
$dout="outd.txt";
#$dout=<>;
#chomp $dout;
open (FD,">$dout");
#print "\nenter the output filename for -number of occurence- matrix\t:";
$out="outp.txt";
#$out=<>;
#chomp $out;
open (FO,">$out");
#print "\nenter the length of motif\t:";
#$colo=<>;
#chomp $colo;
$colo=4;
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
push(@seq,$seq);$tots2=@seqname;
$plan[0][0]=0;
$dist[0][0]=0;

while($colo<10){
for($x11=0;$x11<$tots2;$x11++){$sname=@seqname[$x11];
chomp $sname;
$sname =~ s/\>//g;
$d9=$x11+1;$plan[0][$d9]=$sname;$dist[0][$d9]=$sname;
chomp $testseq;
$testseq=lc(@seq[$x11]);
$len=length($testseq);
print "$sname\n$testseq\n";
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
	if($cont ne "" and $sl eq $colo){$treehash{$cc}=$cont;print "$cc\t$cont\n";
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
foreach $x16 (keys %treehash){delete $treehash{$x16};}
undef %posito;
}
$percent=10;
$threshold=($percent/100)*($tots2+1/1);
$comp=0;
for($d3=0;$d3<=$tots3;$d3++){
for($d2=0;$d2<=$tots2;$d2++){#print "$plan[$d3][$d2]\t";#$dist[$d3][$d2]
                if($plan[$d3+1][$d2+1] ne ""){$comp++ ;
                                         }
        }if($comp ge 1){$thresh{$plan[$d3+1][0]}=$comp;}
        $comp=0;
}
print FO"\t";
print FD"\t";
for($d2=1;$d2<=$tots2;$d2++){print FD"$dist[0][$d2]\t";}print FD"\n";
for($d2=1;$d2<=$tots2;$d2++){print FO"$plan[0][$d2]\t";}print FO"\n";
#@val=sort values %thresh;
#@nval=sort {$b <=> $a} @val;
 #@eldest = sort { $thresh{$b} <=> $thresh{$a} } values %thresh;
#print "@val\n@nval\n@eldest\n";
#for($rr=0;$rr<$#nval;$rr++){foreach $tr1 (keys %thresh) {
#	if(@nval[$rr] eq $thresh{$tr1}){$thresh{$tr1}=@nval[$rr];}
#}}
foreach $uu (sort {$thresh{$b} <=> $thresh{$a}} keys %thresh){

#foreach $uu (keys %thresh){
$tots3=@uniq;
$tots2=@seqname;
print FO"$uu\t";
print FD"$uu\t";
for($d3=1;$d3<=$tots3;$d3++){
for($d2=1;$d2<=$tots2;$d2++){
if($plan[$d3][0] eq $uu) {print FO"$plan[$d3][$d2]\t";print "calc #no. matrix$d3.$d2\n";}
}if($plan[$d3][0] eq $uu) {print FO"$thresh{$uu}\n";}
}
for($d3=1;$d3<=$tots3;$d3++){
for($d2=1;$d2<=$tots2;$d2++){
if($plan[$d3][0] eq $uu) {print FD"$dist[$d3][$d2]\t";print "calc dist matrix$d3.$d2\n";}
}if($plan[$d3][0] eq $uu) {print FD"$thresh{$uu}\n";}
}
#print "$uu : $thresh{$uu}\n";
}
$colo++
}
