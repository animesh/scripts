$file=shift @ARGV;
$fileout=$file.".gp";
open(F,$file);
open(FO,">$fileout");
$lthresh=1500;
$profile=$file;
$profile=~s/An$//;
$profile=shift @ARGV;
$pro=$profile;

while(<F>){
	chomp;
	@temp=split(/\s+/,$_);
	@t=split(/\.\./,@temp[2]);
	if(@t[1] ne "" and @t[0] ne ""){
				$c++;
		print FO"     $profile	     @t[0]..@t[1]\n";
		print FO"     c$pro	     @t[0]..@t[1]\n";
 	}
	else{
		print "$_\n";
	}

}

