#include<stdio.h>
main()
{
	double d;
	int mistake=0;
	FILE *fp_source;
	long int no_of_dataset=0;
	char source[100];
	int count=0;
	printf("Enter the source file: ");
	scanf("%s",source);
	int cols;
	printf("Enter the no of cols: ");
	scanf("%d",&cols);
	
	fp_source=fopen(source,"r");
	if(fp_source==NULL)
		printf("\nERROR Opening file ");
		
	while(!feof(fp_source))
		if(fgetc(fp_source) == '\n')
			no_of_dataset++;
	
	printf("No of rows:: %ld\n",no_of_dataset);
	getchar();
	getchar();
	fclose(fp_source);
	fp_source=fopen(source,"r");
	
	for(long int i=0;i<no_of_dataset;i++)
	{
		for(int j=0;j<cols;j++)
		{
			fscanf(fp_source,"%lf",&d);
			count++;
			if(count>3)
			{
				if(d>1.0||d<0.0)
				{	mistake++;
				
					printf("%ld\n",i);
				}
			}
		}
		count=0;
	}
	printf("\nNo of misnorm is %d\n",mistake);
	
}