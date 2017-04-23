while(<>){
chomp;
$c++;
$_=~s/\s+||\"//g;
if($c%3==0){print "$_\n";}
else{print "$_,";}
}

