#include<stdio.h>
#include<stdlib.h>

main()
{ long Seed;
  int i;

   Seed = (long) time(NULL);

   srand(Seed);

   for(i=0; i<10; i++)
      printf("%d \n", rand()%100);
   printf("\n");
}
