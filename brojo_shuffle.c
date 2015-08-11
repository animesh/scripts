#include<stdio.h>
#include<stdlib.h>
#include<time.h>

int main()
{
	char	inpfile[100],outfile[100];
	FILE	*inpfp,*outfp;
	long	noofdata,i,k;
	int	noofcol,j,ch;
	double  *x;
	int	*tag;
	time_t t;
	
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
	
	tag = (int *)calloc(noofdata,sizeof(int));
	
	i=0;
	
	srand((unsigned)time(&t));
	double k1,k2;
	while(i < 40000)
	{
		k2 = ((double)rand()/32767);
						
		k1=((double)rand()/32767);
		
		k=k1*k2*noofdata;
				
		printf("%d\n",k);		
		while(tag[k] == 1)
		{
			k++;
			if(k >= noofdata)
				k = 0;			
		}
		
		tag[k] = 1;		
		i = i+1;
	}	
	
	outfp = fopen(outfile,"w");
	fclose(outfp);
	
	/********** Memory Allocation ***********/
	
	x = (double *)calloc(noofcol,sizeof(double));
			
	inpfp = fopen(inpfile,"r");
	for(i=0;i<noofdata;i++)
	{
		for(j=0;j<noofcol;j++)
		{
			fscanf(inpfp,"%lf",&x[j]);			
		}
		
		if(tag[i] == 1)
		{
			outfp = fopen(outfile,"a");
			for(j=0;j<noofcol-1;j++)
			{	
				fprintf(outfp,"%030.20lf  ",x[j]);
			}
			fprintf(outfp,"%030.20lf",x[j]);
			fprintf(outfp,"\n");
			fclose(outfp);			
		}		
	}
	
	fclose(inpfp);	
	
	free(x);	
	free(tag);
		
	return(0);	
}
