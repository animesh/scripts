#include<stdio.h>
#include<stdlib.h>
#include<time.h>

void main()
{
	char	inpfile[100],outfile[100];
	FILE	*inpfp,*outfp;
	long	noofdata,noofcol,i,j,ch,seed;
	double 	k;
	double  **x;
	long	*tag,k2;
	time_t t;
	FILE *data;
	
	data=fopen("indexx.txt","w");
	fclose(data);
	
	printf("\nEnter the  input file name\n");
	scanf("%s",inpfile);
	
	printf("\nEnter the output file name\n");
	scanf("%s",outfile);
		
	printf("\nEnter the number of columns\n");
	scanf("%d",&noofcol);
	
	noofdata = 0;
	inpfp = fopen(inpfile,"r");
	while(!feof(inpfp))
	{
		if((ch = getc(inpfp)) == '\n')
			noofdata++;
	}
	fclose(inpfp);	
	
	printf("\nnoofdata = %d\n",noofdata);
	
	
	
	/********** Memory Allocation ***********/
	inpfp = fopen(inpfile,"r");
	x = (double **)calloc(noofdata,sizeof(double *));
	for(i=0;i<noofdata;i++)
		x[i] = (double *)calloc(noofcol,sizeof(double));
		
	
	for(i=0;i<noofdata;i++)
	{
		/*printf("\n%ld",i);		*/
		for(j=0;j<noofcol;j++)
		{
			
			fscanf(inpfp,"%lf",&x[i][j]);			
		}
	}
	fclose(inpfp);
	
	
	tag = (long *)calloc(noofdata,sizeof(long));
	for(long g=0;g<noofdata;g++)
	{
		tag[g]=0;
	}
	i=0;
	
	outfp = fopen(outfile,"w");
	fclose(outfp);
	
	srand((unsigned)time(&t));
	double k1,k3,k4,k5;
	
	long k6,k7,count=0,no=noofdata-1;
	
	while(i < noofdata)
	{		
		
		k6 = noofdata/32767;
		k7 = noofdata%32767;
		/*k = ((double)rand()/32767)*(noofdata-1);*/
		
		k=(double)rand()*(double)(rand()%(k6+1))+(double)(rand()%(k7));		
		
		k2=(long)k;		
		while(tag[k2] != 0)
		{
			count++;
			
			
			if(count>10)
			{
				k2 = no;
				no--;
				count=0;
				
			}
			else{	
			k=(double)rand()*(double)(rand()%(k6+1))+(double)(rand()%(k7));
			
			/*k = ((double)rand()/32767)*(noofdata-1);*/
			
			k2=(long)k;
			if(k2 >= noofdata)
				k2 = 0;
			}
			
		}
		count=0;
		tag[k2] = 1;	
		printf("%ld\n",k2);
		
		outfp = fopen(outfile,"a");
		data=fopen("indexx.txt","a");
		
		for(j=0;j<noofcol-1;j++)
		{	
			fprintf(outfp,"%030.25lf  ",x[k2][j]);
		}
		fprintf(outfp,"%030.25lf",x[k2][j]); 
			
			int i5;
			fprintf(data,"%11ld  ",k2);
			for( i5=26;i5>0;i5--)
			fprintf(data,"%01.1lf  ",x[k2][j-i5]);
			fprintf(data,"%01.1lf\n",x[k2][j-i5]);
		
			
		fclose(data);
		
		fprintf(outfp,"\n");
	
		fclose(outfp);		
		
		i = i+1;
		printf("\ni=%ld\n",i);
	
	}	
				
	printf("\ni=%ld\n",i);
	
	for(i=0;i<noofdata;i++)
		free(x[i]);
	free(x);	
	
	free(tag);
		
	return;	
}
