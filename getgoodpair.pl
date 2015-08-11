#-bash-3.2$ head Pwgs6dhmovlcod.posmap.mates.good
#190m01
#-bash-3.2$ head Pwgs6dhmovlcod.posmap.frgscf.sorted.distpair
open(F2,"Pwgs6dhmovlcod.posmap.frgscf.sorted.distpair");
open(F1,"Pwgs6dhmovlcod.posmap.mates.good");
#2 22a15 7180001551862 7180001551862 474899 417089 475515 417809 r f 57810
while(<F1>){chomp;$_=~s/\s+//g;push(@tmp1,$_)}
while(<F2>){chomp;push(@tmp2,$_)}
foreach $v1 (@tmp1) { 
	foreach $v2 (@tmp2) { 
		#print "$v1\t$v2\n";
		@tmp4=split(/\s+/,$v2);
			if(@tmp4[1] eq $v1){
				print "$v2\n";
				last;
			}
			 
	}
}

