#!/usr/bin/perl
# bac2pair.pl     sharma.animesh@gmail.com     2009/03/22 01:04:42
#Converts format >codbac-190o01.fb140_b1.SCF length=577 sp3=clipped to >DJS045A03F template=DJS054A03 dir=F library=DJS045
while(<>){
        if($_=~/^>/){
       	   $cnt++;
   	   my @tmp=split(/\s+/,$_);
	   my $name=$_;
	   $name=~s/\s+//g;
   	   my $namesubstr=substr($tmp[0],8,6);
 	   my $dirstring=uc(substr($tmp[0],15,1));
 	   my $libstring=substr($tmp[0],1,6);
           print "$name\ttemplate=$namesubstr\tdir=$dirstring\tlibrary=$libstring\n";    
        }
	else{print}
}

