#!/usr/bin/perl
if( @ARGV ne 2){die "\nUSAGE\t\"ProgName SeparatedSeqFile\t Annotated\n\n\n";}
$filess = shift @ARGV;$cp=0;$cnp=0;
$fileas = shift @ARGV;$cp=0;$cnp=0;
open (F1, $filess) || die "can't open \"$filess\": $!";
open (F2, $fileas) || die "can't open \"$fileas\": $!";
while ( $line = <F1> ) 	{
			chomp ($line);
             		push(@name1,$line);
            		}
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
open (F,">$filess.".".$fileas");
foreach $n1 (@name1){
	@temp1=split(/\s+/,$n1);
	$t1=@temp1[1];
	for($c1=0;$c1<=$#seq;$c1++){
	        @temp2=split(/\s+/,@seqname[$c1]);
	        $t2=@temp2[1];
		if($t1 eq $t2)
			{
			print F"$n1\t@seqname[$c1]\n@seq[$c1]\n";
			}
		}
	}
close F;close FS1,close FS2;
