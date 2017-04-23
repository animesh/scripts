 #include<stdio.h> 
 #include<stdlib.h> 
 #include<math.h> 
 int  ROW =512,COL=512;


double MAX,MIN; 
 
 double max=0,min=1000;
 int xcor,ycor;
 
int main() 
 { 
  int i,j,**dim; 
double **sim, coef=0.0; 
 FILE *fr,*fw,*ftp,*fdim; 
 
 fr = fopen("Magnitude.txt","r"); 
 if(fr==NULL) 
 	printf("ERROR:READING\n"); 
 
 fw = fopen("image.pgm","wb"); 
   if(fw == NULL) 
   	printf("ERROR in WRITTING\n"); 
 
   ftp = fopen("sim.txt", "w"); 
   fdim = fopen("dim.txt","w"); 
 
sim =(double**)calloc(ROW,sizeof(double*)); 
dim =(int**)calloc(ROW,sizeof(int*)); 
 
for(i=0;i<ROW;i++) 
{ 
	sim[i] = (double*)calloc(COL,sizeof(double)); 
   dim[i] = (int*)calloc(COL,sizeof(int)); 
} 
 
for(i=0;i<ROW;i++) 
{ 
	for(j=0;j<COL-1;j++) 
	{ 
   	  fscanf(fr,"%lf",&sim[i][j]); 
		
	   if(max<sim[i][j])
	   {
	   	max=sim[i][j];
	   	ycor=i;
	   	xcor=j;
	   }
	   if(min>sim[i][j])
	   	min=sim[i][j];
	   	
	  fprintf(ftp ,"%lf ",sim[i][j]); 
	   
   } 
   	fscanf(fr,"%lf",&sim[i][j]); 
		
	   if(max<sim[i][j])
	   {
	   	max=sim[i][j];
	   	ycor=i;
	   	xcor=j;
	   }
	   if(min>sim[i][j])
	   	min=sim[i][j];
	   	
	  fprintf(ftp ,"%lf",sim[i][j]); 
	fprintf(ftp,"\n"); 
} 
 
 MAX=max;
 MIN=min;
 
coef = (double)(255.0/log((double)(1.0+MAX))); 


/*coef=(double)255.0/(MAX-MIN);*/

 
printf("\ncoeff=%lf\n",coef); 

printf("\nycor=%d xcor=%d %lf\n",ycor,xcor,max); 

 


for(i=0;i<ROW;i++) 
 
{	 
	for(j=0;j<COL;j++) 
	{ 
		if(sim[i][j]<0)
			sim[i][j]=0.0;
		dim[i][j]=(int)(coef*log(1+fabs(sim[i][j])));
		
		
/*		dim[i][j]=(int)(coef*sim[i][j]);*/
		if(dim[i][j]>255)
			dim[i][j]=255;
			
		fprintf(fdim," %d",dim[i][j]); 
		 
	} 
		fprintf(fdim,"\n"); 
} 
 printf("%d", dim[ROW/2][COL/2]);
fprintf(fw,"P5\n"); 
fprintf(fw,"%d %d\n",COL,ROW); 
fprintf(fw,"255\n"); 
 
 
for(i=0;i<ROW;i++) 
{ 
	for(j=0;j<COL;j++) 
	{		 
 
		fprintf(fw,"%c",(char)dim[i][j]); 
	} 
 
	
} 
 
 
for(i=0;i<ROW;i++) 
{ 
	free(sim[i]); 
	free(dim[i]); 
} 
free(sim); 
free(dim); 
fclose(fr); 
fclose(fw); 
fclose(ftp); 
fclose(fdim); 
return(0); 
 } 
