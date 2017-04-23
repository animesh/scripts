#!/usr/bin/perl

my $main_file=shift @ARGV;
open(FMFAS,$main_file)||die "can't open $main_file";
while ($line = <FMFAS>) {
        chomp ($line);
        if ($line =~ /^>/){
                $snames=$line;
                chomp $snames;
		$snames=~s/\s+/\_/g;
             push(@seqname,$snames);
                if ($seq ne ""){
              push(@seq,$seq);
              $seq = "";
            }
      } else {$seq=$seq.$line;
      }
}push(@seq,$seq);
$seq="";
close FMFAS;

$file=shift @ARGV;
$fileout=$file.".NA.fasta";
open(F,$file)||die "can't open $file";;
open(FO,">$fileout");
$lthresh=100;
$profile=$file;
$profile=~s/An$//;
$pro=$profile;
while(<F>){
	chomp;
	@t=split(/\s+/,$_);
	#print "@t[1] @t[2] @t[3] @t[4]  @t[5] @t[6]\n";
	if(@t[3] ne "NA" and @t[4] ne "NA" and @t[3] ne "" and @t[4] ne ""){
		$c++;
		if(@t[3]<@t[4]){
			$mend=@t[3]+@t[2]-1;
			if(@t[2]>$lthresh){
				push(@start,@t[3]);
				push(@end,$mend);
			}
		}
                else{
			$mend=@t[4]+@t[2]-1;
			if(@t[2]>$lthresh){
				push(@start,@t[4]);
				push(@end,$mend);
			}
                }
 	}
	else{
		#print "$_\n";
		push(@seqNA,@t[0]);
	}

}
close F;

my $sno;
for(my $c=0;$c<=$#seq;$c++){
    for(my $c2=0;$c2<=$#seqNA;$c2++){
    	if($seqname[$c]eq$seqNA[$c2]){
    		$sno++;
    		print FO"$seqname[$c]\n$seq[$c]\n";
    		print "$sno\t$seqname[$c]\n";
		last;
    	}
    }	
}
close FO;

