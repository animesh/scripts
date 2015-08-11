/*******************************************************************************/
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>

/*******************************************************************************/

FILE *imagefile;

int image_flag[512][1024];

int 	noNN,NN,inpNode,hidNode,outNode,epoc=0,iter=0;
int	i,t,j,k,fp=0,tp=0,tn=0,fn=0,modify,i_test,j_test;
long 	cntTrnData=0,misTst=0,cntTstData=1,Misclsf = 0,cntTstData_ori=0;
int	ch,misc=0,amaxInd,dmaxInd;
double 	**wih,**who,**pwih,**cwih,**pwho,**cwho,**trnData,**tstData;
double	**aoutput,*delta_inp;
double	sse=0,prevsse=0,n=.9;
double 	**err,**aoutput2,*outdelta;
double	*netValHid,*hidActiv,*netValOup,*doutTrn,*outActiv,**doutTst,d;
double	**wih1,**wih2,**wih3,**wih4,**who1,**who2,**who3,**who4,**clsCntr;
double 	*fOut,*pfOut,*fOut1;
double 	eDis,sumGate,*max,*min;
char	file[50],file1[50];
char 	p[2];
FILE 	*fr,*fw;
char 	trainingfile[50],*testingfile,statusfile[50],ihfile[50],hofile[50],*index_ours;

double *iv;

void memory_allocation();
void initialize(int);
int testing(double *);
double sigmoid(double);		
double distance(int);
int tempx,tempy,color;
char c;		
int return_value;

FILE * fout;


void main()
{
	
	fout=fopen("output.txt","w");
	fclose(fout);
	
	double dist,dist1;
	int cluster_index;
	
	testingfile=(char*)malloc(60*(sizeof(char)));
	imagefile=fopen("neural_image219.pgm","w");
	
	fprintf(imagefile,"%s%d %d%c%d","P5",1024,1024,'\n',255);
	
	
	fclose(imagefile);
	
	/*printf("Enter the iname of input test file: ");
	scanf("%s",testingfile);*/
	
	strcpy(testingfile,"full219_norm.txt");
	
	
	printf("Length of input vector: ");
	scanf("%d",&inpNode);
	
	printf("Length of output vector: ");
	scanf("%d",&outNode);
	
	hidNode = 23;
	
	iv=(double*)calloc(inpNode+outNode,sizeof(double));
	
	
	memory_allocation();
	strcpy(file1,"center.txt");
	
	fr = fopen(testingfile,"r");
	
	while(!feof(fr))
	{
		if((ch=getc(fr))=='\n')
			cntTstData_ori++;
			
	}
	fclose(fr);
	
	printf("\nTest Data = %d\n",cntTstData_ori);
	
	/*********READING THE CLUSTER CENTERS**********/
	
	FILE *f1=fopen(file1,"r");
	for(i=0 ; i<4 ; i++)
	{
		for(j=0 ; j<inpNode ; j++)
		{
			fscanf(f1,"%lf",&clsCntr[i][j]);
			
		}
	}
	fclose(f1);
	
	
	
	fr = fopen(testingfile,"r");
	
/******************************************************READ ORIGINAL IMAGE*********************************************/
	FILE * ori_image;
	
	ori_image=fopen("mdb219.pgm","r");
	
	fscanf(ori_image,"%s%d %d%c%d",p,&tempx,&tempy,&c,&color);
	
	printf("Original File Read\n");

/***************************	printf("%s %d %d %d ",p,tempx,tempy,color);*************************************/

/***********************************************READ THE IMAGE INDEX FILE**********************************************/

	FILE *imageindex;
	imageindex=fopen("imageflag.txt","r");
	
	for(int i_temp=0;i_temp<512;i_temp++)
	{	
		for(int j_temp=0;j_temp<1024;j_temp++)
		{
			fscanf(imageindex,"%4d",&color);

			image_flag[i_temp][j_temp]=color;
		}
		
	}
	
	printf("Image Index File Read\n");

/****************************************************************************************************************************/
	
		
	for(int i_temp=0;i_temp<512;i_temp++)
	{	
		for(int j_temp=0;j_temp<1024;j_temp++)
		{
			c=fgetc(ori_image);
			
			if(image_flag[i_temp][j_temp]==0)
			{
				imagefile=fopen("neural_image219.pgm","a");
				fputc(c,imagefile);
				fclose(imagefile);
			}
			else{
				for(j_test = 0 ; j_test <(inpNode+outNode) ; j_test++)
				{
					fscanf(fr,"%lf",&iv[j_test]);
				
				}
		
				dist = distance(0);
				cluster_index = 0;
				for(int p=1;p<4;p++)
				{
					dist1 = distance(p);
					if(dist1 < dist)
					{
						dist = dist1;
						cluster_index = p;
					}
				}
		
				/*initialize(cluster_index);*/
				initialize(3);
			
				
			
				return_value=testing(iv);
			
				if(return_value==0)
				{
					
					imagefile=fopen("neural_image219.pgm","a");
					c=(char)0;
					fputc(c,imagefile);
					fclose(imagefile);

				}
				else 
				{		
				
					imagefile=fopen("neural_image219.pgm","a");
					c=(char)255;
					fputc(c,imagefile);
					fclose(imagefile);
				}
							
		  	}
	      	}
	
	}	
	
	
	printf("First Part End \n");
	fclose(fr);
	



/***********************************************************************SECOND PART BEGIN***************************************************/
	
	free(testingfile);
	testingfile=(char*)malloc(60*(sizeof(char)));
	
	strcpy(testingfile,"full219_2_norm.txt");
	fr = fopen(testingfile,"r");

/***********************************************READ THE IMAGE INDEX FILE**********************************************/

	
	imageindex=fopen("imageflag2.txt","r");/****CHANGE IMAGE FLAG**********/
	
	for(int i_temp=0;i_temp<512;i_temp++)
	{	
		for(int j_temp=0;j_temp<1024;j_temp++)
		{
			fscanf(imageindex,"%4d",&color);

			image_flag[i_temp][j_temp]=color;
		}
		
	}
	printf("\nRACHED\n");

/****************************************************************************************************************************/
	
	j_test=0;
	
	for(int i_temp=0;i_temp<512;i_temp++)
	{	
		for(int j_temp=0;j_temp<1024;j_temp++)
		{
			c=fgetc(ori_image);
			
			if(image_flag[i_temp][j_temp]==0)
			{
				imagefile=fopen("neural_image219.pgm","a");
				fputc(c,imagefile);
				fclose(imagefile);
			}
		else{
			for(j_test = 0 ; j_test <(inpNode+outNode) ; j_test++)
			{
				fscanf(fr,"%lf",&iv[j_test]);
				
			}
		
			dist = distance(0);
			cluster_index = 0;
			for(int p=1;p<4;p++)
			{
				dist1 = distance(p);
				if(dist1 < dist)
				{
					dist = dist1;
					cluster_index = p;
				}
			}
		
			initialize(cluster_index);
			/*initialize(3);*/
			return_value=testing(iv);
			
			if(return_value==1)
			{
				
				imagefile=fopen("neural_image219.pgm","a");
				fputc(c,imagefile);
				fclose(imagefile);

			}
			else
			{
				imagefile=fopen("neural_image219.pgm","a");
				c=(char)255;
				fputc(c,imagefile);
				fclose(imagefile);
			}			
		  }
	      }
	
	}	
	
	
	
	fclose(fr);
	


/***************************************************************************************************************************************************/

	
	
}




void 	initialize(int j2)
{
	
	FILE 	*f1;	
	
	/**********READING THE WEIGHT FILES*****************/
   
   switch(j2)
   {
   
   	case 0:
   		
		f1 = fopen("/user1/home/brojo/cluster1_dir/wih56","r");
		if(f1==NULL)
			printf("severe ERROR");
			
		
		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{
				
				
				fscanf(f1,"%lf",&wih[i][j]);
				
			}
			
			
		}
		
		fclose(f1);
		
		f1 = fopen("/user1/home/brojo/cluster1_dir/who56","r");
		for(i=0 ; i<outNode ; i++)
		{
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
			}
		}
		fclose(f1);
			
		break;
	
	case 1:
		hidNode = 23;
		f1 = fopen("/user1/home/brojo/cluster2_dir/wih50","r");
		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{
				fscanf(f1,"%lf",&wih[i][j]);
			
			}
		}
		fclose(f1);
		
		
		f1 = fopen("/user1/home/brojo/cluster2_dir/who50","r");
		for(i=0 ; i<outNode ; i++)
		{
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
			}
		}
		fclose(f1);
				
		break;
	
	case 2:
		hidNode = 23;
		f1 = fopen("/user1/home/brojo/cluster3_dir/wih50","r");


		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{
				fscanf(f1,"%lf",&wih[i][j]);
			
			}
		}
		fclose(f1);
		
		
		f1 = fopen("/user1/home/brojo/cluster3_dir/who50","r");
		for(i=0 ; i<outNode ; i++)
		{	
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
				
			}
		}
		fclose(f1);		
			
		break;
	
	case 3: 
		hidNode = 23;
		f1 = fopen("/user1/home/brojo/cluster4_dir/wih41","r");
		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{
				fscanf(f1,"%lf",&wih[i][j]);
				
			}
		}
		fclose(f1);
		
		
		f1 = fopen("/user1/home/brojo/cluster4_dir/who41","r");
		for(i=0 ; i<outNode ; i++)
		{
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
				
			}
		}
		fclose(f1);	
			
		break;
	default:
		printf("Only four clusters available\n");
		break;
		
	
	/*f1 = fopen("/user1/home/brojo/cluster1_dir/who56","r");
	for(i=0 ; i<outNode ; i++)
	{
		for(j=0 ; j<hidNode ;j++)
		{
			fscanf(f1,"%lf",&who1[i][j]);
		}
	}
	fclose(f1);*/
	
	/*f1 = fopen("/user1/home/brojo/cluster2_dir/who50","r");
	for(i=0 ; i<outNode ; i++)
	{
		for(j=0 ; j<hidNode ;j++)
		{
			fscanf(f1,"%lf",&who2[i][j]);
		}
	}
	fclose(f1);*/
	
	/*f1 = fopen("/user1/home/brojo/cluster3_dir/who50","r");
	for(i=0 ; i<outNode ; i++)
	{
		for(j=0 ; j<hidNode ;j++)
		{
			fscanf(f1,"%lf",&who3[i][j]);
			
		}
	}
	fclose(f1);*/
	
	/*f1 = fopen("/user1/home/brojo/cluster4_dir/who41","r");
	for(i=0 ; i<outNode ; i++)
	{
		for(j=0 ; j<hidNode ;j++)
		{
			fscanf(f1,"%lf",&who4[i][j]);
			
		}
	}
	fclose(f1);*/
	
   };/*end switch*/
   
   			
	
	return;
}
/***********************************************************************/

/*************     MEMORY ALLOCATION     ********************************/
void memory_allocation()
{
	int 	i;
	
	
	/******************************copied from testing***********************************************************/

	netValHid = (double*)calloc(hidNode,sizeof(double));
	hidActiv = (double*)calloc(hidNode,sizeof(double));	
	netValOup = (double*)calloc(outNode,sizeof(double));
	outActiv=(double*)calloc(outNode,sizeof(double));
	
	tstData = (double**)calloc(cntTstData,sizeof(double*));
		if(tstData == NULL)
		{
			printf("\n Error tstData\n");
		}
		for( i = 0 ; i < cntTstData ; i++)
		{
			tstData[i] = (double*)calloc((inpNode+outNode),sizeof(double));
			if(tstData[i] == NULL)
			{
			
				printf("\n Error tstData[%d]",i);
			}
		}
	
	
	
	
	doutTst = (double**)calloc(cntTstData,sizeof(double*));
		
		if(doutTst == NULL)
		{
			printf("\n Error doutTst\n");
			exit(0);
		}
		for(i=0 ; i<cntTstData ; i++)
		{
			doutTst[i] = (double*)calloc(outNode,sizeof(double));
		}	
		
		
	aoutput2 = (double**)calloc(cntTstData,sizeof(double*));
		for(i=0 ; i<cntTstData ; i++)
		{
			aoutput2[i] = (double*)calloc(outNode,sizeof(double));
			
		}
		

/***********************************************************************************************/
	
	
	
	
	
	doutTrn = (double *)calloc(outNode,sizeof(double));	
	
	/*********DYNAMIC MEMORY ALLOCATION FOR THE WEIGHT ARRAY*********/
	
	wih = (double**)calloc(hidNode,sizeof(double*));
	/*wih2 = (double**)calloc(hidNode,sizeof(double*));
	wih3 = (double**)calloc(hidNode,sizeof(double*));
	wih4 = (double**)calloc(hidNode,sizeof(double*));
	if((wih1 == NULL) || (wih2 == NULL) || (wih3 == NULL))
	{
		printf("\n Error in wih's\n");
		exit(0);
	}*/
	
	for(i=0 ; i<hidNode ; i++)
	{
		wih[i] = (double*)calloc(inpNode,sizeof(double));
		/*wih2[i] = (double*)calloc(inpNode,sizeof(double));	
		wih3[i] = (double*)calloc(inpNode,sizeof(double));
		wih4[i] = (double*)calloc(inpNode,sizeof(double));
		if((wih1[i] == NULL) || (wih2[i] == NULL) || (wih3[i] == NULL))
		{
			printf("\n Error in wih1's\n");
			exit(0);
		}*/
	}
	
	who = (double**)calloc(outNode,sizeof(double*));
	/*who2 = (double**)calloc(outNode,sizeof(double*));
	who3 = (double**)calloc(outNode,sizeof(double*));
	who4 = (double**)calloc(outNode,sizeof(double*));
	if((who1 == NULL) || (who2 == NULL) || (who3 == NULL))
	{
		printf("\n Error in who's \n");
		exit(0);
	}*/		
	for(i=0 ; i<outNode ; i++)
	{
		who[i] = (double*)calloc(hidNode,sizeof(double));
		/*who2[i] = (double*)calloc(hidNode,sizeof(double));
		who3[i] = (double*)calloc(hidNode,sizeof(double));
		who4[i] = (double*)calloc(hidNode,sizeof(double));
		if((who1[i] == NULL) || (who2[i] == NULL) || (who3[i] == NULL))
		{
			printf("\n Error in who1's\n");
			exit(0);
		}*/
		
	}
	
	/********DYNAMIC MEMORY ALLOCATION FOR THE TRAINING DATA********/
	
	/********DYNAMIC MEMORY ALLOCATION TO STORE THE CLUSTER CENTERS******/
	
	clsCntr = (double**)calloc(4,sizeof(double*));
	if(clsCntr == NULL)
	{
		printf("\n Error in clsCntr\n");
		exit(0);
	}
	for(i=0 ; i<4 ; i++)
	{
		clsCntr[i] = (double*)calloc(inpNode,sizeof(double));
		if(clsCntr[i] == NULL)
		{
			printf("\n Error in clsCntr's\n");
			exit(0);
		}
	}
	
	
}

double distance(int i)
{
	double sum,temp;
	int l;
	
	sum=0;
	for(l=0 ; l<inpNode ; l++)
	{
		
		sum+=(clsCntr[i][l] - iv[l])*(clsCntr[i][l] - iv[l]);
	}	
	temp = sqrt(sum);
	return(temp);
	
	
}				


int testing(double *iv1)
{		
		
	
	/*********READING THE TESTING FILE**************/
		
	for(i=0;i<inpNode+outNode;i++)
	{
		tstData[0][i]=iv1[i];
	}
		
		/********DYNAMIC MEMORY ALLOCATION FOR THE DESIRED OUTPUT ARRAY*******/
		
		
		for(i = 0 ; i < cntTstData ; i++)
		{
			for(j=0 ; j<outNode; j++)
			{
				doutTst[i][j] = tstData[i][inpNode+j];
				
			}	
		}
		
		
		
		cntTstData=1;	
		for( k = 0 ; k <cntTstData ; k++)
		{
		
			for(i = 0 ; i <hidNode ; i++)
			{
				netValHid[i] = hidActiv[i] = 0;
				for(j = 0 ; j < inpNode ; j++)
				{
					netValHid[i]+= (wih[i][j] * tstData[k][j]);
				}
			}
			
			for(i = 0 ; i < hidNode ; i++)
			{
				hidActiv[i] = sigmoid(netValHid[i]);
			}
			
			for(i = 0 ; i < outNode ; i++)
			{
				netValOup[i] = 0;
				aoutput2[k][i] = 0;
				for(j = 0 ; j < hidNode ; j++)
				{
					netValOup[i]+= (who[i][j] * hidActiv[j]);
				}
			}
			
			for(i = 0 ;i< outNode ; i++)
			{
				aoutput2[k][i] = sigmoid(netValOup[i]);
				
			}
			
			/*amaxInd = 0;
			dmaxInd = 0;
			for(i=0 ; i<(outNode-1) ;i++)
			{
				if((aoutput2[k][amaxInd])<aoutput2[k][i+1])
				{
					amaxInd = i+1;
				}
				
				if(doutTst[k][dmaxInd]<doutTst[k][i+1])
				{
					dmaxInd = i+1;
				}
				
			}*/
			
			amaxInd = 0;
			dmaxInd = 0;
			if(((aoutput2[k][0])<(aoutput2[k][1])))
				{
					amaxInd = 1;
				}
				
				if(doutTst[k][0]<doutTst[k][1])
				{
					dmaxInd = 1;
				}
					
			
			/***************************************OUPT^PUTWRITEFILE*******************/
			
				
				fout=fopen("output.txt","a");
				fprintf(fout,"%16.15lf  %16.15lf  %16.15lf\n",netValOup[0],aoutput2[k][0],aoutput2[k][1]);
				fclose(fout);
			
			
			/****************************************************************************/
	
			if(amaxInd!=dmaxInd)
			{
				misTst++;
			}
			if((amaxInd == 0) && (dmaxInd == 1))
			{
				fp++;
				
			}
			if((amaxInd == 0) && (dmaxInd == 0))
			{
				tp++;
				
			}
			if((amaxInd == 1) && (dmaxInd == 0))		
			{
				fn++;
				
			}
			if((amaxInd == 1) && (dmaxInd == 1))
			{
				tn++;
				
			}				
		
		}
		printf("\n The testing misclassification....%d",misTst);
		printf("\n The pixels negative but giving positive...%d",fp);
		printf("\n The pixels positive and giving positive...%d",tp);
		printf("\n The pixels positive but giving negative...%d",fn);
		printf("\n The pixels negative and giving negative...%d",tn);
		
		/*if(amaxInd!=dmaxInd)
			{
				return 0;
			}
		else
		{
			return 1;
		}*/
		
		return(amaxInd);
	
	return;			
			
	
}


/******************************************************************************/
double sigmoid(double x)
{
	double sig;
	double d;
	d=exp(-x);
	d=d+1;
	sig = (double)(1/d);
	return(sig);
}
/******************************************************************************/	
