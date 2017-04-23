/******************************************************
Program : Fuzzy C-mean Clustering 

******************************************************/
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<sys/time.h>

/*****************************************************/
int 	c;
unsigned int seed;
int 	n=0,ch;
int 	f;
double 	mv_err = 0.0000001;
double 	z_err = 0.0001;
double 	**x, **z, **u; 
/*****************************************************/

void 	initial_mv_matrix(); 
double 	distance(double **, double **,int, int);
void 	proto_type_update();
void 	mv_matrix_update();
void 	Read_data();
void 	copy_u(double **);
void 	copy_z(double **);
int 	Error_matrices(double **);
int 	Error_proto(double **);
time_t t;
/*****************************************************/
double *sum;
void main()
{
 	int	i,j,k,cl,*count;
 	int 	error=1,error1 =0;
 	double 	**U,**Z,m;
 	FILE 	*fp;
 	int 	*pcls,*ncls;
 	char 	filename[50],filename1[50];
 	
 	printf("\nEnter the number of clusters\n");
 	scanf("%d",&c);
 	
 	printf("\nEnter the number of features\n");
 	scanf("%d",&f);
 	
 	Read_data();

 	z = (double**)calloc(c,sizeof(double*));
 	U = (double**)calloc(c,sizeof(double*));
 	Z = (double**)calloc(c,sizeof(double*));
 	count = (int*)calloc(c,sizeof(int));
 	
 	for(i=0; i <c; i++)
 	{
		z[i] = (double*)calloc(f , sizeof(double));
		U[i] = (double*)calloc(n , sizeof(double));
		Z[i] = (double*)calloc(f , sizeof(double));
		
		if((z[i] == NULL) || (U[i] == NULL))
		{
			printf("error\n");
			exit(1);
		}
 	} 	
 	
 	sum=(double*)malloc(f*sizeof(double));
 	initial_mv_matrix();
 	
 		
 	while(error) 
 	{ 
		proto_type_update();
		copy_u(U);				
		mv_matrix_update();
		error = Error_matrices(U);
 	}
 	
 	/*while(error1) 
 	{ 
		proto_type_update();
		copy_z(Z);
		mv_matrix_update();
		error1 = Error_proto(Z);
 	}
 	*/
 	printf("\nEnter the file name to store the centers\n");
 	scanf("%s",filename1);
 	fp = fopen(filename1,"w");
 	for(i=0;i<c;i++)
 	{
 		for(j=0;j<f-1;j++)
 			fprintf(fp,"%16.15lf  ",z[i][j]);
 		fprintf(fp,"%16.15lf",z[i][j]);
 		fprintf(fp,"\n");
 	}
 	fclose(fp);
 	
 	printf("\nEnter the file name\n");
 	scanf("%s",filename);
 	
 	fp = fopen(filename,"w");
 	for(j=0; j<n; j++)
 	{
  		m=0.0;
  		for(i=0; i<c; i++)
  		{
			if(u[i][j] > m)
			{
				m=u[i][j];
				cl=i;
			}
  		}
  		count[cl]++;
  
  		fprintf(fp,"\n%d %d ",j,cl);
  
 	}
 	fclose(fp);
 
 	for(i=0; i<c; i++)
		printf("%d ",count[i]);
 	printf("\n");
 
 	pcls=(int *)calloc(c,sizeof(int));
 	ncls=(int *)calloc(c,sizeof(int));
 
 	fp = fopen(filename,"r");
 	for(i=0;i<n;i++)
 	{
 		fscanf(fp,"%d%d",&j,&cl);
 	
 		if(j%2==0)
 			pcls[cl]=pcls[cl]+1;
 		else 
 			ncls[cl]=ncls[cl]+1;
 	}
 
 	for(i=0;i<c;i++)
 		printf("\ncls[%d] = %d  + %d\n",i,pcls[i],ncls[i]);
 
 	free(pcls);
 	free(ncls); 	

 	return; 

}


/****************************************************/

void initial_mv_matrix() 
{
 	int 	i,j;
 	double 	*temp,s=0; 	
	
	
 	temp=(double* )calloc(c,sizeof(double));
 	if(temp == NULL)
 	{
 		printf("memory error\n");
 		exit(1);
 	}
 	
 	u = (double**)calloc(c,sizeof(double*));
 	for(i=0; i < c; i++)
		u[i] = (double*)calloc(n, sizeof(double));
	
	
 	/*seed = time(NULL);
 	srand(seed); 	*/
 	srand((unsigned)time(&t));
 	
 	for(i=0; i <n; i++)
 	{
		s=0;
		for(j=0; j <c;j++)
		{			
			temp[j] = (double)rand()/32767;			
			s += temp[j];
		}
		for(j=0; j<c; j++)
			u[j][i] = temp[j]/s;
 	}
 	free(temp);
 	
 	return;
}
/*****************************************************/
double distance(double **p1, double **p2,int k,int i)
{
 	int 	i1;
 	double 	t1,t;
 	double 	sum=0;

 	for(i1=0; i1<f; i1++)
 	{
		t1 = p1[k][i1] - p2[i][i1];
		sum = sum + t1 * t1;
 	}
 	t = sqrt(sum);
 	return(t);
}
/*****************************************************/
void proto_type_update()
{
 	int 	i,j,k;
 	double 	ut,s=0;

 	for(i=0; i<c; i++)
 	{
 		s = 0;
 		
  		
  		for(k=0;k<n;k++)
  		{	
  			ut = u[i][k];
  			s+=ut*ut;
  		}
  		
  		for(j=0; j<f; j++)
		{
			sum[j]=0.0;
		}
		
  		
  		for(k=0; k<n; k++)
  		{			
			
			for(j=0; j<f; j++)
			{			
				/*sum += ut * ut * x[k][j];*/
				
				sum[j]+=u[i][k]*u[i][k]*x[k][j];
			}
		  	
  		}


		for(j=0; j<f; j++)
		{
			z[i][j] = sum[j]/s;
		}
	
  	}
  	return;
}
/*****************************************************************************/
void mv_matrix_update()
{
 	int 	i,j,k;
 	double 	dik,djk,temp,sum=0;

 	for(i=0; i <c; i++)
 	{
  		for(k=0; k<n; k++)
  		{
			sum =0;
			/*dik= distance(x[k], z[i]);*/
			
			dik= distance(x, z,k,i);
			
			for(j=0; j<c; j++)
			{
				/*djk = distance(x[k], z[j]);*/
				
				djk = distance(x, z,k,j);
				
				temp = (double)dik/djk;
				sum = sum + temp * temp;
			}
			temp = 1.0/sum;
			u[i][k] = temp;
  		}
  	}
  	return;
}
/*****************************************************/
void Read_data()
{
 	int 	i,j;
 	double 	ignore;
 	FILE 	*fp;
 	char 	file[50];
 	
 	printf("\nEnter the input file name\n");
 	scanf("%s",file);
 	
 	fp = fopen(file,"r");
 	while(!feof(fp))
	{
		if((ch=getc(fp))=='\n')
			n++;
			
	}	
 	fclose(fp);
 	
 	x = (double**)malloc(n * sizeof(double*));
 
 	for(i=0; i <n; i++)
 	{
		x[i] = (double*)malloc(f * sizeof(double));
		if(x[i] == NULL)
		{
			printf("memory error\n");
			exit(1);
		}
 	}
 	
 		
 	fp = fopen(file,"r");
 	for(i=0; i<n; i++)
 	{
  		for(j=0; j<f;j++)
  		{
			fscanf(fp,"%lf",&x[i][j]);
  		}
  		for(j=0; j<2;j++)
  		{
			fscanf(fp,"%lf",&ignore);
  		}
 	}
 	
 	fclose(fp);
 	return;
}
/*****************************************************/
int Error_matrices(double **U)
{
 	int 	i,j,error=0;
 	double 	temp;

 	for(i=0; i<c; i++)
 	{
  		for(j=0; j<n; j++)
  		{
			temp = U[i][j] - u[i][j];
			if(fabs((double)temp) > mv_err) 
				return 1;
  		}
  	}
 	return 0;
}
/*****************************************************/
int Error_proto(double **Z)
{
 	int 	i,j,error=0;
 	double 	temp;
 	double sum;

 	for(i=0; i<c; i++)
 	{
  		sum = 0;
  		for(j=0; j<f; j++)
  		{
			temp = Z[i][j] - z[i][j];
			sum += temp * temp;
  		}
  		if(sum > z_err) 
  			return 1;
 	}
 	return 0;
}
/*****************************************************/
void copy_u(double **U)
{
 	int 	i,j;

 	for(i=0; i<c; i++)
 	{
  		for(j=0; j<n; j++)
  		{
			U[i][j] = u[i][j];
  		}
  	}
  	return;
}
/*****************************************************/
void copy_z(double **Z)
{
 	int 	i,j;

 	for(i=0; i<c; i++)
 	{
  		for(j=0; j<f; j++)
  		{
			Z[i][j] = z[i][j];
  		}
  	}
  	return;
}
/*****************************************************/