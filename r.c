#include <stdio.h>
void main(){
int c,f;
scanf("%d",&c);
f=fact(c);
printf("fact is =%d\n",f);


}
int fact(int n)
{
if (n == 0|| n==1)
{
return 1;
}
else{
return(n*fact(n-1));
}
}
