#!/usr/bin/perl
if( @ARGV ne 1){die "\nUSAGE\t\"ProgName GenomeFile\n\n\n";}
$fileas = shift @ARGV;$cp=0;$cnp=0;
#open (F1, $filess) || die "can't open \"$filess\": $!";
open (F2, $fileas) || die "can't open \"$fileas\": $!";
#while ( $line = <F1> ) 	{
#			chomp ($line);
#             		push(@name1,$line);
#            		}
$seq="";
while ($line = <F2>) {
        chomp ($line);
        if ($line =~ /^>/){
             push(@seqname,$line);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}
push(@seq,$seq);
open (F,">$fileas."."lsavg");
for($c1=0;$c1<=$#seq;$c1++){
	        @temp2=split(/\:/,@seqname[$c1]);$seqc=uc(@seq[$c1]);
	        $t2=@temp2[1];
		@temp2=split(/\,/,$t2);
		$t2=@temp2[0];
		@temp2=split(/\-/,$t2);
		$v1=@temp2[0];$v2=@temp2[1];
		if($v1=~/^c/)
		{
		@temp2=reverse@temp2;$v1=@temp2[0];$v2=@temp2[1];
			$v2=~s/c//;}
			$lenc=length($seqc);$lena+=$lenc;
			push(@temp4,$v1);push(@temp4,$v2);
			push(@temp5,$lenc);
			print F"@seqname[$c1]\tG\t$v1\-$v2\t$lenc\n";
		}
$vt=@temp4;
for($cc=0;$cc<($vt-3);$cc=$cc+2)
{	$v1=@temp4[$cc+1];
	$v2=@temp4[$cc+2];
	$vv=$v2-$v1;$vva+=$vv;push(@temp6,$vv);
	$ccn=$cc/2;
print F"$seqname[$ccn+1]\-$seqname[$ccn]\tIG\t@temp4[$cc]\t@temp4[$cc+1]\t$vv\n";
}
$vvavg=$vva/$c1;
$lavg=$lena/$c1;
@temp5=sort {$a<=>$b} (@temp5);
@temp6=sort {$a<=>$b} (@temp6);
print "\nthe list in  $fileas.lsavg\n";
open (FG,">$fileas."."G.txt");
print "\nthe length array in file $fileas.G.txt\n";
foreach $e (@temp5){print FG"$e\n";};
open (FIG,">$fileas."."IG.txt");
print "\nthe length array in file $fileas.IG.txt\n";
foreach $e (@temp6){print FIG"$e\n";};
print F"avg length\t$lavg\navg intergenic length\t$vvavg\n";
close F;
close FG;close FIG;
