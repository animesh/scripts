$file=shift @ARGV;
$fileout=$file.".fgp";
open(F,$file);
open(FO,">$fileout");
$lthresh=1000;

while(<F>){
	chomp;
	@t=split(/\s+/,$_);
	if(@t[3] ne "NA" and @t[4] ne "NA" and @t[3] ne "" and @t[4] ne ""){
		$c++;
		if(@t[3]<@t[4]){
			$mend=@t[3]+@t[2]-1;
			if(@t[2]>$lthresh){
				print FO"@t[3]\t$mend\n";
			}
		}
                else{
			$mend=@t[4]+@t[2]-1;
			if(@t[2]>$lthresh){
				print FO"@t[4]\t$mend\n";
			}
                }
 	}
	else{
		print "$_\n";
	}

}

