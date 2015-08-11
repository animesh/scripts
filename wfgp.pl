$file=shift @ARGV;
$fileout=$file.".fgp";
open(F,$file);
open(FO,">$fileout");
$scale=100;

while(<F>){
	chomp;
	@t=split(/\s+/,$_);
	if(@t[3] ne "NA" and @t[4] ne "NA" and @t[3] ne "" and @t[4] ne ""){
		$c++;
		if(@t[3]<@t[4]){
			$mend=(@t[3]+@t[2]-1)/$scale;
			$msta=@t[3]/$scale;
			print FO"$msta\t1\n$mend\t1\n\n";
		}
                else{
			$mend=(@t[4]+@t[2]-1)/$scale;
			$msta=@t[4]/$scale;
			print FO"$msta\t1\n$mend\t1\n\n";
                }
 	}
	else{
		print "$_\n";
	}

}
