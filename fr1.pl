system ("ls -1 > t.1");
open F,"t.1";
while($l=<F>){
chomp $l;
open FF, $l;
#print $l;
open FFF,">./temp/$l";
while($lll=<FF>){
#print $lll;
#open FFF,">./temp/$l";
if($lll =~ /\#\!/ ){
$lll =~ s/\#\!\ /\#\!/g;
print FFF "\#\!\/usr\/bin\/perl\n";
}
else{
print FFF "$lll";
}
}
}
