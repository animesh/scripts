#include<stdio.h>
#include<stdlib.h>
#include<time.h>

int main()
{	time_t t;
	char	inpfile1[100],inpfile2[100],outfile[100];
	FILE	*inpfp1,*inpfp2,*outfp;
	long	noofdata,noofcol,i,j,k1,k2,kk1,kk2,cnt1=0,cnt2=0,ch,seed;
	double  **x1,**x2,**y;
	long	*postag,*negtag;
	
	printf("\nEnter the first input file name\n");
	scanf("%s",inpfile1);
	
	printf("\nEnter the second input file name\n");
	scanf("%s",inpfile2);
	
	printf("\nEnter the output file name\n");
	scanf("%s",outfile);
		
	printf("\nEnter the number of columns\n");
	scanf("%d",&noofcol);
	
	inpfp1 = fopen(inpfile1,"r");
	while(!feof(inpfp1))
	{
		if((ch = getc(inpfp1)) == '\n')
			cnt1++;
	}
	fclose(inpfp1);
	
	inpfp2 = fopen(inpfile2,"r");
	while(!feof(inpfp2))
	{
		if((ch = getc(inpfp2)) == '\n')
			cnt2++;
	}
	fclose(inpfp2);
	
	printf("\ncnt1 = %ld",cnt1);
	printf("\ncnt2 = %ld\n",cnt2);
	
	/*printf("\nEnter no of data");
	scanf("%d",&noofdata);*/
	noofdata=cnt1+cnt2;
	
	
	postag = (long *)calloc(cnt1,sizeof(long));
	negtag = (long *)calloc(cnt2,sizeof(long));	
	
	/********** Memory Allocation ***********/
	
	x1 = (double **)calloc(cnt1,sizeof(double *));
	for(i=0;i<cnt1;i++)
		x1[i] = (double *)calloc(noofcol,sizeof(double));
		
	x2 = (double **)calloc(cnt2,sizeof(double *));
	for(i=0;i<cnt2;i++)
		x2[i] = (double *)calloc(noofcol,sizeof(double));
		
	y = (double **)calloc(noofdata,sizeof(double *));
	
	for(i=0;i<noofdata;i++)
		y[i] = (double *)calloc(noofcol,sizeof(double));	
		
	inpfp1 = fopen(inpfile1,"r");
	for(i=0;i<cnt1;i++)
	{
		printf("%ld\n",i);
		for(j=0;j<noofcol;j++)
		{
			fscanf(inpfp1,"%lf",&x1[i][j]);			
		}
	}
	fclose(inpfp1);
	
	inpfp2 = fopen(inpfile2,"r");
	
	for(i=0;i<cnt2;i++)
	{
		printf("%ld\n",i);
		
		for(j=0;j<noofcol;j++)
		{
			fscanf(inpfp2,"%lf",&x2[i][j]);			
		}
	}
	fclose(inpfp2);	
	
	
	for(long g=0;g<cnt1;g++)
	{
		postag[g]=0;
	}
	
	for(long g=0;g<cnt2;g++)
	{
		negtag[g]=0;
	}
	i=0;
	printf("READ COMPLETE\n");
	
	srand((unsigned)time(&t));
	
	outfp = fopen(outfile,"w");
	long count=0,no1=0,no2=0,fin1=0,fin2=0,d=0;
	
	
	while(i < noofdata)
	{
		printf("\n%ld",i);		
		
		k1 = (long)(((double)rand()/32767)*cnt1);
		k1 = k1%cnt1;
		
		kk1 = k1;
		
		while((postag[k1] == 1)&&fin1<=cnt1)
		{
			
			count++;
			if(count>1000)
			{
				k1=no1;
				no1++;
				count=0;
			}
			else{
				k1 = (long)(((double)rand()/32767)*noofdata);
				k1 = k1%cnt1;
			}
			
		}
		
		fin1++;
		
	
		if(fin1<=cnt1)
		{	
			postag[k1] = 1;	
			printf("k1=%ld\n",k1);	
			for(j=0; j<noofcol-1; j++)
				fprintf(outfp,"%030.25lf  ",x1[k1][j]);
		
			fprintf(outfp,"%030.25lf\n",x1[k1][j]);
			i=i+1;
		}
		printf("REACHED\n");
		if(d>(cnt1-cnt2)-10)
		{
			k2 = (long)(((double)rand()/32767)*cnt2);
			k2 = k2%cnt2;
		
			kk2 = k2;
			count=0;
			while((negtag[k2] == 1)&&(fin2<=cnt2))
			{
				count++;
				if(count>1000)
				{
					k2=no2;
					no2++;
					count=0;
				}
				else{
					k2 = (long)(((double)rand()/32767)*cnt2);
					k2 = k2%cnt2;
			  	    }
			}
		
			fin2++;
		
			if(fin2<=cnt2)
			{
				negtag[k2] = 1;
				printf("k2=%ld\n",k2);
			
				for(j=0;j<noofcol-1;j++)
				{
					fprintf(outfp,"%030.25lf  ",x2[k2][j]);			
				}
				fprintf(outfp,"%030.25lf\n",x2[k2][j]);
				i=i+1;
			}
		
		}
		d++;
	}	
	
			
	
	
	fclose(outfp);
	
	for(i=0;i<cnt1;i++)
		free(x1[i]);
	free(x1);
	
	for(i=0;i<cnt2;i++)
		free(x2[i]);
	free(x2);
		
	for(i=0;i<noofdata;i++)
		free(y[i]);
	free(y);
	
	free(postag);
	free(negtag);	
	
	return(0);	
}
