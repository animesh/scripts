#!/usr/bin/perl
#>codbac29j5-2o21.rp2_b1.SCF    883      0    883  SCF
# bac2pair.pl     sharma.animesh@gmail.com     2009/03/22 01:04:42
#>codbac181n17-1a01.rp2_b1.SCF CHROMAT_FILE: codbac181n17-1a01.rp2_b1.SCF PHD_FILE: codbac181n17-1a01.rp2_b1.SCF.phd.1 CHEM: term DYE: big TIME: Wed Mar 17 10:36:37 2010
#Converts format >codbac-190o01.fb140_b1.SCF length=577 sp3=clipped to >DJS045A03F template=DJS054A03 dir=F library=DJS045
while(<>){
        if($_=~/^>/){
		$_=~s/\>//g;
           $cnt++;
           my @tmp=split(/\s+/,$_);
           my $name=@tmp[0];
           my @tmp=split(/\./,$name);
           my $namesubstr=@tmp[0];
           my $dirstring="";
		if(@tmp[1]=~/^f/){
           $dirstring="F";}
		if(@tmp[1]=~/^r/){
	$dirstring="R";}
           my @tmp=split(/\-/,$namesubstr);
           my $libstring=@tmp[0];
	   my $tempstring="$libstring@tmp[1]";
	  print ">$name$cnt\ttemplate=$tempstring\tdir=$dirstring\tlibrary=$libstring\n";   
        }
        else{print}
}

