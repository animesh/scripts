#!/usr/bin/perl
# user input asking programme for motif ALGO
@base=qw/a t c g/;
print "\nenter the multiple seq. containing fasta file name\t:";
$file=<>;
chomp $file;
open(F,$file)||die "can't open";
print "\nenter the output filename\t:";
$out=<>;
chomp $out;
open (FO,">$out");
print "\nenter the length of motif\t:";
$colo=<>;
chomp $colo;
$seq = "";
while ($line = <F>) {
        chomp ($line);
        if ($line =~ /^>/){
             @seqn=split(/\t/,$line);
             push(@seqname,@seqn[0]);
             $cc++;
            if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
push(@seq,$seq);
#$colo=6;
#$coloo=$colo;
#while($coloo ne 0)
#{
#for($cn=0;$cn<$colo;$cn++)
#	{
#
#	}
#}
if($colo eq 6){foreach $b1 (@base){foreach $b2 (@base){foreach $b3 (@base){foreach $b4 (@base){foreach $b5(@base){foreach $b6 (@base){$comb=$b1.$b2.$b3.$b4.$b5.$b6;push(@combos,$comb);}}}}}}}
if($colo eq 4){foreach $b1 (@base){foreach $b2 (@base){foreach $b3 (@base){foreach $b4 (@base){$comb=$b1.$b2.$b3.$b4;push(@combos,$comb);}}}}}
if($colo eq 8){foreach $b1 (@base){foreach $b2 (@base){foreach $b3 (@base){foreach $b4 (@base){foreach $b5(@base){foreach $b6 (@base){foreach $b7 (@base){foreach $b8 (@base){$comb=$b1.$b2.$b3.$b4.$b5.$b6.$b7.$b8;push(@combos,$comb);}}}}}}}}}
if($colo eq 2){foreach $b1 (@base){foreach $b2 (@base){$comb=$b1.$b2;push(@combos,$comb);}}}
if($colo eq 3){foreach $b1 (@base){foreach $b2 (@base){foreach $b3 (@base){$comb=$b1.$b2.$b3;push(@combos,$comb);}}}}
if($colo eq 10){foreach $b1 (@base){foreach $b2 (@base){foreach $b3 (@base){foreach $b4 (@base){foreach $b5(@base){foreach $b6 (@base){foreach $b7 (@base){foreach $b8 (@base){foreach $b9 (@base){foreach $b10 (@base){$comb=$b1.$b2.$b3.$b4.$b5.$b6.$b7.$b8.$b9.$b10;push(@combos,$comb);}}}}}}}}}}}
$tots2=@seqname;
#$tots3=1;
$plan[0][0]=0;
for($x11=0;$x11<$tots2;$x11++){#for($d1=0;$d1<$tots3;$d1++){
$sname=@seqname[$x11];
$sname =~ s/\>//g;
$d9=$x11+1;$plan[0][$d9]=$sname;
#print "$plan[$d9][0]\t";
$testseq=lc(@seq[$x11]);
$len=length($testseq);
for($co2=0;$co2<$len;$co2++)
	{
$subs=substr($testseq,$co2,$colo);
push(@seqcod,$subs);
	}
	$cont1=0;
foreach $x12 (@combos){
        foreach $x13 (@seqcod){
                     if($x12 eq $x13)
						 {#print "$x12\n";
						push(@fran,$x12);
						$cont1++;$treehash{$x12}=$cont1;
						}
        			}
			$cont1=0;
	}
$cont1=0;
$cont3=0;
@seqcod=0;
%seen=();
@uniq = grep{ !$seen{$_} ++} @fran;
$tots3=@uniq;
for($d6=1;$d6<=$tots3;$d6++)
	{
	$d7=$d6-1;$plan[$d6][0]=@uniq[$d7];
	}
for($d4=1;$d4<=$tots3;$d4++)
		{foreach $d5 (keys %treehash) {$d7=$x11+1;
	if($plan[$d4][0] eq $d5){$plan[$d4][$d7]=$treehash{$d5};}
		}}
foreach $x16 (keys %treehash){delete $treehash{$x16};}
foreach $x30 (keys %posit){delete $posit{$x30};}
}
$tots3=@uniq;
$tots2=@seqname;
for($d3=0;$d3<=$tots3;$d3++){print FO"\n";
	for($d2=0;$d2<=$tots2;$d2++){
	print FO"$plan[$d3][$d2]\t";
}}