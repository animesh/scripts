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
open (F,">$fileas."."gclen");
$seqc=join(//,@seq);
                        $cc=$seqc=~s/G/G/g; 
                        $gc=$seqc=~s/C/C/g; 
                        $lenc=length($seqc);
                        $gcp=(($cc+$gc)/$lenc)*100; 
                        print F"$fileas\t$gcp\t$lenc\n\n";

for($c1=0;$c1<=$#seq;$c1++){
	        @temp2=split(/\s+/,@seqname[$c1]);$seqc=uc(@seq[$c1]);
	        $t2=@temp2[0];
			$cc=$seqc=~s/G/G/g;                        
			$gc=$seqc=~s/C/C/g;
			$lenc=length($seqc);
			$gcp=(($cc+$gc)/$lenc)*100;
			print F"$t2\t$gcp\t$lenc\n";
		}
close F;close FS1,
close FS2;
