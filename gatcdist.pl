while(<>){
chomp;
@v=split(/\t/);
#print length(@v),"\t";
for($c=1;$c<$#v;$c++){print $v[$c+1]-$v[$c],"\n";}
}
