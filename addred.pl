$nint=shift @ARGV;
if($nint<=0){die"Enter number greater then 0"}
print rec($nint);
sub rec {
         $n = shift;
         if($n>0){
                 $sum+=($n);
                 $n--;
                 (rec($n));
         }
         return $sum;
}

