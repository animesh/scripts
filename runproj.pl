$currDir = `pwd`;
chomp $currDir;
$projdir=$currDir;
$projdir=~s/\/assembly//;
$perlscript="editcg.pl";
$cgf=$projdir."/assembly/454ContigGraph.txt";
$csf=$projdir."/assembly/454AllContigs.*";
do{
$cnt++;
$ef="edit".$cnt;
$editcom=$projdir."/assembly/".$ef;
system("perl $perlscript $cgf > $editcom");
if($cnt==100){system("cat tt > $editcom");
}
open(F,$editcom);
$check="";
while($line=<F>){chomp $line;$check.=$line;}
$check=~s/\s+//g;
chomp $check;
close F;
print "$cnt>CD $currDir PD $projdir CNT $cnt EC $editcom EF $ef CGF $cgf $check\n";
system("cp $csf ../../.");
system("runProject -edit $editcom -qo $projdir");
}until($check eq "")

