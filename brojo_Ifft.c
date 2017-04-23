#include<stdio.h>
#include<math.h>
#include<stdlib.h>


FILE *ft,*im,*b,*orere,*oreim,*oimre,*oimim;

int row=512,col=512;
/*char filename[100];*/
double **mag,d,**ift,d1,d2,pi=3.14159;

double **iftre,**iftim,**fre,**fim,**orere_part,**oimre_part,**oreim_part,**oimim_part;;
void main()
{
/*	printf("Enter the mag file name\n");
  	scanf("%s",filename);*/

   /*	mag=(double**)malloc(row*sizeof(double));
	for(int i=0;i<row;i++)
		mag[i]=(double*)malloc(col*sizeof(double));*/

	iftre=(double**)malloc(row*sizeof(double*));
	for(int i=0;i<row;i++)
		iftre[i]=(double*)malloc(col*sizeof(double));

	ift=(double**)malloc(row*sizeof(double*));
	for(int i=0;i<row;i++)
		ift[i]=(double*)malloc(col*sizeof(double));

	iftim=(double**)malloc(row*sizeof(double*));
	for(int i=0;i<row;i++)
		iftim[i]=(double*)malloc(col*sizeof(double));

	fre=(double**)malloc(row*sizeof(double*));
	for(int i=0;i<row;i++)
		fre[i]=(double*)malloc(col*sizeof(double));

	fim=(double**)malloc(row*sizeof(double*));
	for(int i=0;i<row;i++)
		fim[i]=(double*)malloc(col*sizeof(double));

	orere_part=(double**)malloc(row*sizeof(double*));
	for(int i=0;i<row;i++)
		orere_part[i]=(double*)malloc(col*sizeof(double));


	oreim_part=(double**)malloc(row*sizeof(double*));
	for(int i=0;i<row;i++)
		oreim_part[i]=(double*)malloc(col*sizeof(double));


	oimre_part=(double**)malloc(row*sizeof(double*));
	for(int i=0;i<row;i++)
		oimre_part[i]=(double*)malloc(col*sizeof(double));

	oimim_part=(double**)malloc(row*sizeof(double*));
	for(int i=0;i<row;i++)
		oimim_part[i]=(double*)malloc(col*sizeof(double));


	orere=fopen("REALre.txt","r");
	oreim=fopen("REALim.txt","r");
	oimre=fopen("IMre.txt","r");
	oimim=fopen("IMim.txt","r");
	if((orere==NULL)||(oreim==NULL))
	 {	printf("ERROR\n");
		exit(0);
	 }


/*	ft=fopen(filename,"r");*/

	for(int i=0;i<row;i++)
		for(int j=0;j<col;j++)
		{
		 /*	fscanf(ft,"%lf",&d);
		  	mag[i][j]=d;*/

			fscanf(orere,"%lf",&d);
			orere_part[i][j]=d;
			fscanf(oreim,"%lf",&d);
			oreim_part[i][j]=d;

			fscanf(oimre,"%lf",&d);
			oimre_part[i][j]=d;
			fscanf(oimim,"%lf",&d);
			oimim_part[i][j]=d;

		}

	/*fclose(ft);*/
	fclose(orere);
	fclose(oimre);
	fclose(oreim);
	fclose(oimim);
	printf("Enter the loop\n");



/*for(int u=0;u<row;u++)

	for(int y=0;y<col;y++)
	{
		iftre[u][y]=0.0;
		iftim[u][y]=0.0;
		for(int v=0;v<col;v++)
		{
			d=(double)(6.28
			*v*y);
			d=d/(double)col;

			iftre[u][y]+=ore_part[u][v]*cos(d)-oim_part[u][v]*sin(d);

			iftim[u][y]+=ore_part[u][v]*sin(d)+oim_part[u][v]*cos(d);


		}
	}*/



	 for(int v=0;v<col;v++)
	for(int x=0;x<row;x++)
	{
		iftre[x][v]=0.0;
		iftim[x][v]=0.0;
		for(int u=0;u<row;u++)
		{
			d=(double)(2*pi*u*x)/row;
			d1=cos(d);
			d2=sin(d);
			iftre[x][v]+=orere_part[u][v]*d1-oreim_part[u][v]*d2;
			iftim[x][v]+=oimre_part[u][v]*d1-oimim_part[u][v]*d2;
		}
	}


	b=fopen("outimaginary.txt","w");

	for(int x=0;x<row;x++)
	{
		for(int y=0;y<col;y++)
		{

			fprintf(b,"%lf ",iftim[x][y]);
		}
		fprintf(b,"\n");
	}

	fclose(b);




	b=fopen("outreal.txt","w");

	for(int x=0;x<row;x++)
	{
		for(int y=0;y<col;y++)
		{

			fprintf(b,"%lf ",iftre[x][y]);
		}
		fprintf(b,"\n");
	}

	fclose(b);


/*for(int y=0;y<col;y++)
	for(int x=0;x<row;x++)
	{
		fre[x][y]=0.0;
		fim[x][y]=0.0;
		for(int u=0;u<row;u++)
		{
			fre[x][y]+=iftre[u][y]*cos((6.28*u*x)/row)-iftim[u][y]*sin((6.28*u*x)/row);

		}
	}*/

printf("First Part End\n");
	 for(int x=0;x<row;x++)

	for(int y=0;y<col;y++)
	{
		fre[x][y]=0.0;
		fim[x][y]=0.0;
		for(int v=0;v<col;v++)
		{
				d=(double)(2*pi*v*y)/col;
			d1=cos(d);
			d2=sin(d);
		   /*	if(d/6.28==0)
			{
			  d1=1.0;
			  d2=0.0;
			  }
			if(d/3.14==0)
			{
			  d1=-1.0;
			  d2=0.0;
			  }*/
			fre[x][y]+=iftre[x][v]*d1-iftim[x][v]*d2;
			fim[x][y]+= iftre[x][v]*d2+iftim[x][v]*d1;
		}
	}

	b=fopen("IMAGINARY.txt","w");

	for(int x=0;x<row;x++)
	{
		for(int y=0;y<col;y++)
		{

			fprintf(b,"%lf ",fim[x][y]);
		}
		fprintf(b,"\n");
	}

	fclose(b);


	b=fopen("test.txt","w");

	for(int x=0;x<row;x++)
	{
		for(int y=0;y<col;y++)
		{
			if(((x+y)%2)==1)
				fre[x][y]=(-1)*fre[x][y];
			fprintf(b,"%lf ",fre[x][y]);
		}
		fprintf(b,"\n");

	}
printf("second Part End\n");
	fclose(b);
	char dhut;
	int color;

	im=fopen("INV.pgm","w");
	fprintf(im,"%s\n%d %d\n%d\n","P5",col,row,255);

	for(int x=0;x<row;x++)
		for(int y=0;y<col;y++)
		{

			color=(int)fre[x][y];
			if(color<0)
				color=0;
			dhut=(char)color;
			fputc(dhut,im);
		}

		fclose(im);

/*	for(int i=0;i<row;i++)
 		free(mag[i]);
	free(mag);*/
	for(int i=0;i<row;i++)
		free(ift[i]);
	free(ift);

}