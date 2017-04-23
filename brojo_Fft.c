#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>

int **image,row,col;
double pi=3.14159;
/***************************************************************************/
int main()
{
		int clr,i,j,x,u,v,y;
		char ch;
		double  **FRE,**FIM,**FFTREre,**FFTREim,**FFTIMre,**FFTIMim;
		double magnitude;
		char a[3];


		 FILE *fr,*fw,*magFile,*rere,*reim,*imre,*imim;

		fr=fopen("trial_c.pgm","r");
		if(fr==NULL)
		{
			printf("ERROR\n");
			exit(0);
		}

		fw=fopen("image.txt","w");
		if(fw==NULL)
		{
			printf("ERROR\n");
			exit(0);
		}

		fscanf(fr,"%s%d %d%d%c",a,&col,&row,&clr,&ch);


		/*row=100;
		col=100;*/
		
		/*fclose(fr);*/
		
		printf("col = %d row =%d  clr = %d\n",col, row, clr);

		FRE=(double**)calloc(row,sizeof(double*));
		 for(int n=0;n<row;n++)
			FRE[n]=(double*)calloc(col,sizeof(double));

		 FIM=(double**)calloc(row,sizeof(double*));
		 for(int n=0;n<row;n++)
			FIM[n]=(double*)calloc(col,sizeof(double));


		  FFTREre=(double**)calloc(row,sizeof(double*));
		 for(int n=0;n<row;n++)
			FFTREre[n]=(double*)calloc(col,sizeof(double));
		 FFTREim=(double**)calloc(row,sizeof(double*));
		 for(int n=0;n<row;n++)
			FFTREim[n]=(double*)calloc(col,sizeof(double));

		FFTIMre=(double**)calloc(row,sizeof(double*));
		 for(int n=0;n<row;n++)
			FFTIMre[n]=(double*)calloc(col,sizeof(double));

		FFTIMim=(double**)calloc(row,sizeof(double*));
		 for(int n=0;n<row;n++)
			FFTIMim[n]=(double*)calloc(col,sizeof(double));

		image = (int**)calloc(row,sizeof(int*));
		if( image == NULL )
		{
			printf("Error in first calloc.\n");
			exit(0);
		}

		for(int i=0;i<row;i++)
		{
			image[i] = (int*)calloc(col,sizeof(int));
			if( image[i] == NULL )
			{
				printf("Error in first calloc.\n");
				exit(0);
			}
		}
		 int flag=0,color;


		/*fr=fopen("rnd512.txt","r");
		if(fr==NULL)
			printf("ERROR");*/
			
		for(int i=0;i<row;i++)
		{
				for(int j=0;j<col;j++)
				{
						ch=fgetc(fr);
					/*	fscanf(fr,"%d%c",&color,&ch);*/
					
						color=(int)ch;
						
						image[i][j]=color;

						if(((i+j)%2)==1)
							image[i][j]=(-1)*image[i][j];
						fprintf(fw,"%d ",image[i][j]);

				}
				fprintf(fw,"\n");
		}

		/*image[0][0]=0;image[0][1]=0;image[0][2]=0;image[0][3]=0;image[1][0]=0;image[1][1]=255;
		image[1][2]=255;image[1][3]=0;image[2][0]=0;image[2][1]=255;image[2][2]=255;;image[2][3]=0;
		image[3][0]=0;image[3][1]=0;image[3][2]=0;;image[3][3]=0;*/

		/* FILE *uf;
		 uf=fopen("data.txt","w");

		for(int i=0;i<row;i++)
		{
				for(int j=0;j<col;j++)
				{
			   
					image[i][j]=(int)(rand()%1000);
				 
					if(((i+j)%2)==1)
							image[i][j]=(-1)*image[i][j];
					fprintf(uf,"%d ",image[i][j]);
				}
				fprintf(uf,"\n");
		}*/

		fclose(fw);
		/*fclose(uf);*/
		
		fclose(fr);

		fw = fopen("fftimage.txt","w");
		if( fw == NULL )
		{
			printf("Error Opening file fftimage.txt\n");
			exit(0);
		}

			FILE *cossin;
			cossin=fopen("e:\\cossin.txt","w");

		for(x=0;x<row;x++)
		{
			for(v=0;v<col;v++)/*changed row to col***/
			{
				FRE[x][v]=0.0;
				FIM[x][v] = 0.0;

				for(y=0;y<col;y++)
				{
				  FRE[x][v]+=(double)((image[x][y] * cos(y*v * 2*pi/col)));
				  FIM[x][v]-=(double)((image[x][y] * sin(y*v * 2*pi/col)));
         		 	
				  if(x==19&&v==19)
				  fprintf(cossin,"%d %lf  %lf\n",y, cos(y*v * 2*pi/col)/col,sin(y*v * 6.28/col)/col);
				}
				FRE[x][v]=FRE[x][v]/col;
				FIM[x][v]=FIM[x][v]/col;

			}
		}
		fclose(cossin);
		printf("Entering the loop.\n");
		FILE *ft;
		ft=fopen("orifre.txt","w");
		int l;
		for(int k=0;k<row;k++)
		{
			for( l=0;l<col-1;l++)
			{
				fprintf(ft,"%lf  ",FRE[k][l]);
			}
			fprintf(ft,"%lf\n",FRE[k][l]);
	   }
	   fclose(ft);

		ft=fopen("ORIIM.txt","w");
		for(int k=0;k<row;k++)
		{
			for(int l=0;l<col-1;l++)
			{
				fprintf(ft,"%lf ",FIM[k][l]);
			}
			fprintf(ft,"%lf\n",FIM[k][l]);
	   }
	   fclose(ft);
		rere=fopen("REALre.txt","w");
		reim=fopen("REALim.txt","w");
		imre=fopen("IMre.txt","w");
		imim =fopen("IMim.txt","w");
		for(v=0;v<col;v++)		/*for(u=0;u<row;u++)*/
		 {

			 for(u=0;u<row;u++)	/*for(v=0;v<col;v++)*/
			 {
				 FFTREre[u][v]=0.0;
				 FFTIMre[u][v]=0.0;
				 FFTREim[u][v]=0.0;
				 FFTIMim[u][v]=0.0;

				 for(x=0;x<row;x++)
				 {
				   	FFTREre[u][v]+= (double)((FRE[x][v] * cos(x*u * 2*pi/row)));
				 	FFTREim[u][v]-=(double)((FRE[x][v] * sin(x*u * 2*pi/row)));
					FFTIMim[u][v]-= (double)((FIM[x][v] * sin(x*u * 2*pi/row)));
					FFTIMre[u][v]+=(double)((FIM[x][v] * cos(x*u * 2*pi/row)));
					
					
				 }
				 FFTREre[u][v]=FFTREre[u][v]/row;
				 FFTREim[u][v]=FFTREim[u][v]/row;
				 FFTIMre[u][v]=FFTIMre[u][v]/row;
				 FFTIMim[u][v]=FFTIMim[u][v]/row;
				 fprintf(fw,"%16.12lf + %16.12lf  ",FFTIMre[u][v],FFTIMim[u][v]);
			 }
			 fprintf(fw,"\n");
		 }



		printf("Opening Magnitude file.\n");
		magFile = fopen("Magnitude.txt","w");
		if( magFile == NULL )
		{
			 printf("Error Opening File Magnitude.txt.\n");
			exit(0);
		}


		for(u=0;u<row;u++)
		 {
			 for(v=0;v<col-1;v++)
			{

				magnitude = sqrt((FFTREre[u][v]-FFTIMim[u][v])*(FFTREre[u][v]-FFTIMim[u][v]) +(FFTREim[u][v]+FFTIMre[u][v])*(FFTREim[u][v]+FFTIMre[u][v]));
				
				fprintf(magFile,"%lf ",magnitude);
				fprintf(rere,"%lf ",FFTREre[u][v]);
				fprintf(reim,"%lf ",FFTREim[u][v]);

				fprintf(imre,"%lf ",FFTIMre[u][v]);
				fprintf(imim,"%lf ",FFTIMim[u][v]);

			}
				fprintf(rere,"%lf\n",FFTREre[u][v]);
				fprintf(reim,"%lf\n",FFTREim[u][v]);
				fprintf(imre,"%lf\n",FFTIMre[u][v]);
				fprintf(imim,"%lf\n",FFTIMim[u][v]);

				magnitude = sqrt((FFTREre[u][v]-FFTIMim[u][v])*(FFTREre[u][v]-FFTIMim[u][v]) +(FFTREim[u][v]+FFTIMre[u][v])*(FFTREim[u][v]+FFTIMre[u][v]));
				fprintf(magFile,"%lf\n",magnitude);

		}
		fclose(rere);
		fclose(reim);
		fclose(imre);
		fclose(imim);
		fflush( magFile );
		fclose(magFile);
		fflush(fw);
		fclose(fw);

		for(i=0;i<row;i++)
		 free(image[i]);
		free(image);
		return(0);
		
}
 