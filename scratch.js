function fact(x) {
   if(x==0) {
      return 1;
   }
   return x * fact(x-1);
}
console.log(fact(4))
function dbl (x){return x*2;}
y=dbl(5)
z=dbl(y)
z+y
