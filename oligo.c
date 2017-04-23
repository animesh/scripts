#include<stdio.h>
#include <string.h>
int main()
{
int i = 0,j=1;
char c;
char arr[50000];
char temp[65];
char buff[300];

FILE* fp;
memset(temp,'\0',sizeof(temp));
memset(buff,'\0',sizeof(buff));
fp = fopen("./gene", "r");


c=fgetc(fp);
while (c != EOF){

arr[i]=c;
c=fgetc(fp);
i++;
}
arr[i] = '\0';
fclose(fp);
fp = fopen("./gene1", "w");
for(i = 0; i< (strlen(arr)/10 - 6); i++)
{
 strncpy(temp,arr+10*i, 60);
 fputc('>',fp);
 j=i;
 fprintf (fp,"%d",i);
 fputc('\n',fp);

 fputs(temp,fp);
  fputc('\n',fp);


 fputc('\n',fp);
 printf("\n%s",temp);

}
fclose(fp);
system(" blastall -p blastn -d /usr/bin/data/ecoli.nt -i gene1 -o khu") ;
printf("\n\n%s",arr);

return 0;
}
