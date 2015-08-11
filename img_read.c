
       /*program for reading a pgm file and then write a new file */
#include<stdio.h>
#include<stdlib.h>

void main()
{

char ch[2],chr;
int s,s1,i,j,g=0;
FILE *fp=fopen("im_3.pgm","rb");/*enter prev file name*/
FILE *fp1=fopen("im_44.pgm","wb");/*enter new file name*/


fscanf(fp,"%s",ch);
fscanf(fp,"%d %d",&s,&s1);


fscanf(fp,"%d",&g);


printf("%s\n",ch);
printf("%d %d\n",s,s1);

fp1=fopen("im_4.pgm","wb");

fprintf(fp1,"%s\n",ch);
fprintf(fp1,"%d %d\n",s,s1);
fprintf(fp1,"%d\n",g);




for(i=0;i<s;i++)
   for(j=0;j<s1;j++)
    {
         fscanf(fp,"%c",&chr);
         fprintf(fp1,"%c",chr); 

     }


fclose(fp);
fclose(fp1);



}