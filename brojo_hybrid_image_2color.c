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
int prev_cluster_index;
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
double **image_info,d1,d2,d3;

FILE *wrong;
char *str;

int initialise;
/*******************************************************************************/
void main()
{
	
	double dist,dist1;
	int cluster_index;
	
	printf("Length of input vector: ");
	scanf("%d",&inpNode);
	
	printf("Length of output vector: ");
	scanf("%d",&outNode);
	
	fout=fopen("output.txt","w");
	fclose(fout);
	
	/*printf("Enter the iname of input test file: ");
	scanf("%s",testingfile);*/	
	
	testingfile=(char*)malloc(60*(sizeof(char)));
	strcpy(testingfile,"full218_test_norm.txt");
	
	wrong=fopen("wrongpos218","w");
	fclose(wrong);
	
	wrong=fopen("wrongneg218","w");
	fclose(wrong);
	
	fr = fopen(testingfile,"r");
	
	while(!feof(fr))
	{
		if((ch=getc(fr))=='\n')
			cntTstData_ori++;
			
	}
	fclose(fr);
	
	printf("\nTest Data = %d\n",cntTstData_ori);	
	
	imagefile=fopen("image218_neural_ori.pgm","w");	
	if(imagefile==NULL)
	{
		printf("ERROR CREATING FILE\n");
	}
	fprintf(imagefile,"%s\n%d %d%c%d","P5",1024,1024,'\n',255);	
	fclose(imagefile);
	
	iv=(double*)calloc(inpNode+outNode,sizeof(double));	
	
	strcpy(file1,"centers.txt");	
	
	clsCntr = (double**)calloc(8,sizeof(double*));
	if(clsCntr == NULL)
	{
		printf("\n Error in clsCntr\n");
		exit(0);
	}
	for(i=0 ; i<8 ; i++)
	{
		clsCntr[i] = (double*)calloc(inpNode,sizeof(double));
		if(clsCntr[i] == NULL)
		{
			printf("\n Error in clsCntr's\n");
			exit(0);
		}
	}
	
	/*********READING THE CLUSTER CENTERS***********************************************************************/
	
	/*FILE *f1=fopen(file1,"r");
	for(i=0 ; i<8 ; i++)
	{
		for(j=0 ; j<inpNode ; j++)
		{
			fscanf(f1,"%lf",&clsCntr[i][j]);
			
		}
	}
	fclose(f1);*/
	
	
	
	fr = fopen(testingfile,"r");
	

	/***************************READ ORIGINAL IMAGE***********************************************************/
	FILE * ori_image;
	
	ori_image=fopen("mdb218.pgm","r");
	
	fscanf(ori_image,"%s%d %d%c%d",p,&tempx,&tempy,&c,&color);
	
	printf("Original File Read\n");

	/*********printf("%s %d %d %d ",p,tempx,tempy,color);*************************/

	/****************READ THE IMAGE INDEX FILE**********************************/

	FILE *imageindex;
	imageindex=fopen("imageflag218.txt","r");
	
	
	for(int i_temp=0;i_temp<512;i_temp++)
	{	
		
		for(int j_temp=0;j_temp<1024;j_temp++)
		{
			fscanf(imageindex,"%4d",&color);

			image_flag[i_temp][j_temp]=color;
		}
		
	}
	
	printf("Image Index File Read\n");
	fclose(imageindex);
	/*******************************************************************************/
	
		
	for(int i_temp=0;i_temp<512;i_temp++)
	{	
		printf("%d \n",i_temp);
		for(int j_temp=0;j_temp<1024;j_temp++)
		{
			c=fgetc(ori_image);
			
			if(image_flag[i_temp][j_temp]==0)
			{
				imagefile=fopen("image218_neural_ori.pgm","a");
				fputc(c,imagefile);
				fclose(imagefile);
				printf("WRITTEN\n");
			}
			else{
				printf("READ\n");
				
				



				fscanf(fr,"%lf  %lf  %lf",&d1,&d2,&d3);


				for(j_test = 0 ; j_test <(inpNode+outNode) ; j_test++)
				{
					fscanf(fr,"%lf",&iv[j_test]);
				
				}
				printf("READ COMPLETE\n");
				

				
				
				
				dist = distance(0);
				cluster_index = 0;
				/*for(int p=1;p<4;p++)
				{
					dist1 = distance(p);
					if(dist1 < dist)
					{
						dist = dist1;
						cluster_index = p;
					}
				}*/
		
				printf("READ CLUSTER COMPLETE\n");
				/*initialize(cluster_index);*/
				
				cluster_index=3;
				
				if((cluster_index!=prev_cluster_index)&&(!initialise))
				{
					initialise=1;
					prev_cluster_index=cluster_index;
					
					initialize(cluster_index);	
				
				}
				printf("INITIALIZATION COMPLETE\n");
				if((cluster_index!=prev_cluster_index)&&(initialise))
				{
					prev_cluster_index=cluster_index;
					
						for(i=0 ; i<hidNode ; i++)
						{
							free(wih[i]); 		
		
						}
						free(wih);
						
						for(i=0 ; i<outNode ; i++)
						{
							free(who[i]);
		
						}
						free(who);
						
						
						
					free(netValHid); 
					free(hidActiv);
					free(netValOup);
					free(outActiv);
					
					
					for( i = 0 ; i < cntTstData ; i++)
					{
						free(tstData[i]);
											
					}
					
					free(tstData);
					
					
					
					for(i=0 ; i<cntTstData ; i++)
					{
						free(doutTst[i]); 
					}	
					
					
					free(doutTst);
					
					
					
					for(i=0 ; i<cntTstData ; i++)
					{
						free(aoutput2[i]);
			
					}	
					
					free(aoutput2);
					
					
					initialize(cluster_index);	
				}
				
				
				
			
				return_value=testing(iv);
				
				
							
				if(return_value==0)
				{
					
					str=(char*)calloc(30,sizeof(char));
					strcpy(str,"wrongpos218.txt");
					wrong=fopen(str,"a");
					fprintf(wrong,"%04.0lf  04.0lf  04.0lf\n",d1,d2,d3);
					fclose(wrong);
					free(str);
					
					imagefile=fopen("image218_neural_ori.pgm","a");
					c=(char)255;
					fputc(c,imagefile);
					fclose(imagefile);

				}
				else if(return_value==1)
				{				
				
					imagefile=fopen("image218_neural_ori.pgm","a");
					c=(char)255;
					fputc(c,imagefile);
					fclose(imagefile);
				}
				else if(return_value==2)
				{
					
					
					str=(char*)calloc(30,sizeof(char));
					strcpy(str,"wrongneg218.txt");
					wrong=fopen(str,"a");
					fprintf(wrong,"%04.0lf  04.0lf  04.0lf\n",d1,d2,d3);
					fclose(wrong);
					free(str);
					
					
					imagefile=fopen("image218_neural_ori.pgm","a");
					
					fputc(c,imagefile);
					fclose(imagefile);

				}
				else
				{				
				
					imagefile=fopen("image218_neural_ori.pgm","a");
					
					fputc(c,imagefile);
					fclose(imagefile);
				}				
		  	}
	      	}
	
	}	
	
	
	printf("\nFirst Part End \n");
	fclose(fr);
	



	/*************************SECOND PART BEGIN***************************************/
	
	free(testingfile);
	testingfile=(char*)malloc(60*(sizeof(char)));
	
	strcpy(testingfile,"full218_2_test_norm.txt");
	fr = fopen(testingfile,"r");

	/**********************READ THE IMAGE INDEX FILE*********************************/

	
	imageindex=fopen("imageflag218_2.txt","r");/****CHANGE IMAGE FLAG**********/
	
	for(int i_temp=0;i_temp<512;i_temp++)
	{	
		for(int j_temp=0;j_temp<1024;j_temp++)
		{
			fscanf(imageindex,"%4d",&color);

			image_flag[i_temp][j_temp]=color;
		}
		
	}
	printf("\nRACHED\n");

	/**************************************************************************************/
	
	j_test=0;
	
	for(int i_temp=0;i_temp<512;i_temp++)
	{	
		for(int j_temp=0;j_temp<1024;j_temp++)
		{
			c=fgetc(ori_image);
			
			if(image_flag[i_temp][j_temp]==0)
			{
				imagefile=fopen("image218_neural_ori.pgm","a");
				fputc(c,imagefile);
				fclose(imagefile);
			}
			else{
			
			
				fscanf(fr,"%lf  %lf  %lf",&d1,&d2,&d3);
				
				for(j_test = 0 ; j_test <(inpNode+outNode) ; j_test++)
				{
					fscanf(fr,"%lf",&iv[j_test]);
				
				}
		
				dist = distance(0);
				cluster_index = 0;
				/*for(int p=1;p<4;p++)
				{
					dist1 = distance(p);
					if(dist1 < dist)
					{
						dist = dist1;
						cluster_index = p;
					}
				}*/
		
				/*initialize(cluster_index);*/
				
/*********************************************COPIED FROM FIRST SECTION********************************************************/

				cluster_index=3;
				
				if((cluster_index!=prev_cluster_index)&&(!initialise))
				{
					initialise=1;
					prev_cluster_index=cluster_index;
					
					initialize(cluster_index);	
				}
				
				if((cluster_index!=prev_cluster_index)&&(initialise))
				{
					prev_cluster_index=cluster_index;
					
						for(i=0 ; i<hidNode ; i++)
						{
							free(wih[i]); 		
		
						}
						free(wih);
						
						for(i=0 ; i<outNode ; i++)
						{
							free(who[i]);
		
						}
						free(who);
						
						
						
					free(netValHid); 
					free(hidActiv);
					free(netValOup);
					free(outActiv);
					
					
					for( i = 0 ; i < cntTstData ; i++)
					{
						free(tstData[i]);
											
					}
					
					free(tstData);
					
					
					
					for(i=0 ; i<cntTstData ; i++)
					{
						free(doutTst[i]); 
					}	
					
					
					free(doutTst);
					
					
					
					for(i=0 ; i<cntTstData ; i++)
					{
						free(aoutput2[i]);
			
					}	
					
					free(aoutput2);
					
					
					initialize(cluster_index);	
				}
				
				

	/*******************************************************************************/
				return_value=testing(iv);
			
				if(return_value==0)
				{
					
					str=(char*)calloc(30,sizeof(char));
					strcpy(str,"wrongpos218.txt");
					wrong=fopen(str,"a");
					fprintf(wrong,"%04.0lf  04.0lf  04.0lf\n",d1,d2,d3);
					fclose(wrong);
					free(str);
					
					imagefile=fopen("image218_neural_ori.pgm","a");
					c=(char)255;
					fputc(c,imagefile);
					fclose(imagefile);

				}
				else if(return_value==1)
				{				
				
					imagefile=fopen("image218_neural_ori.pgm","a");
					c=(char)255;
					fputc(c,imagefile);
					fclose(imagefile);
				}
				else if(return_value==2)
				{
					
					str=(char*)calloc(30,sizeof(char));
					strcpy(str,"wrongneg218.txt");
					wrong=fopen(str,"a");
					fprintf(wrong,"%04.0lf  04.0lf  04.0lf\n",d1,d2,d3);
					fclose(wrong);
					free(str);
					
					imagefile=fopen("image218_neural_ori.pgm","a");
					
					fputc(c,imagefile);
					fclose(imagefile);

				}
				else
				{				
				
					imagefile=fopen("image218_neural_ori.pgm","a");
					
					fputc(c,imagefile);
					fclose(imagefile);
				}				
		  	}
	      	}
	
	}	
	
	
	
	fclose(fr);
	
}
/*******************************************************************************/

void 	initialize(int j2)
{
	
	FILE 	*f1;	
	
	/**********READING THE WEIGHT FILES*****************/
   
    switch(j2)
   {
   
   	case 0:
   		
   		/*********DYNAMIC MEMORY ALLOCATION FOR THE WEIGHT ARRAY*********/
   		
   		f1 = fopen("/user1/home/brojo/cluster1_21/wih182","r");
		if(f1==NULL)
			printf("severe ERROR");
		fscanf(f1,"%d %d %lf",&inpNode,&hidNode,&n);
		
		wih = (double**)calloc(hidNode,sizeof(double*));
			
		for(i=0 ; i<hidNode ; i++)
		{
			wih[i] = (double*)calloc(inpNode,sizeof(double));		
		
		}
		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{				
				fscanf(f1,"%lf",&wih[i][j]);				
			}			
		}
		
		fclose(f1);
		
		f1 = fopen("/user1/home/brojo/cluster1_21/who182","r");
		
		fscanf(f1,"%d %d %lf",&hidNode,&outNode,&n);		
		
		who = (double**)calloc(outNode,sizeof(double*));
			
		for(i=0 ; i<outNode ; i++)
		{
			who[i] = (double*)calloc(hidNode,sizeof(double));		
		
		}
		for(i=0 ; i<outNode ; i++)
		{
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
			}
		}
		fclose(f1);
   		
      		
   		/********DYNAMIC MEMORY ALLOCATION FOR THE TRAINING DATA*****************************/
   		
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
	
		/*doutTrn = (double *)calloc(outNode,sizeof(double));*/
			
		break;
	

/*******************************************************************************************************************************/


	case 1:
			
   		/*********DYNAMIC MEMORY ALLOCATION FOR THE WEIGHT ARRAY*********/
   		
   		f1 = fopen("/user1/home/brojo/cluster2_21/wih29","r");
		if(f1==NULL)
			printf("severe ERROR");
		fscanf(f1,"%d %d %lf",&inpNode,&hidNode,&n);
		
		wih = (double**)calloc(hidNode,sizeof(double*));
			
		for(i=0 ; i<hidNode ; i++)
		{
			wih[i] = (double*)calloc(inpNode,sizeof(double));		
		
		}
		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{				
				fscanf(f1,"%lf",&wih[i][j]);				
			}			
		}
		
		fclose(f1);
		
		f1 = fopen("/user1/home/brojo/cluster2_21/who29","r");
		
		fscanf(f1,"%d %d %lf",&hidNode,&outNode,&n);		
		
		who = (double**)calloc(outNode,sizeof(double*));
			
		for(i=0 ; i<outNode ; i++)
		{
			who[i] = (double*)calloc(hidNode,sizeof(double));		
		
		}
		for(i=0 ; i<outNode ; i++)
		{
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
			}
		}
		fclose(f1);
   		
      		
   		/********DYNAMIC MEMORY ALLOCATION FOR THE TRAINING DATA*****************************/
   		
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
	
		/*doutTrn = (double *)calloc(outNode,sizeof(double));*/
			
	
		break;
	
		
/*******************************************************************************************************************************/		
	
	case 2:
		
		
			
   		/*********DYNAMIC MEMORY ALLOCATION FOR THE WEIGHT ARRAY*********/
   		
   		f1 = fopen("/user1/home/brojo/cluster3_21/wih29","r");
		if(f1==NULL)
			printf("severe ERROR");
		fscanf(f1,"%d %d %lf",&inpNode,&hidNode,&n);
		
		wih = (double**)calloc(hidNode,sizeof(double*));
			
		for(i=0 ; i<hidNode ; i++)
		{
			wih[i] = (double*)calloc(inpNode,sizeof(double));		
		
		}
		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{				
				fscanf(f1,"%lf",&wih[i][j]);				
			}			
		}
		
		fclose(f1);
		
		f1 = fopen("/user1/home/brojo/cluster3_21/who29","r");
		
		fscanf(f1,"%d %d %lf",&hidNode,&outNode,&n);		
		
		who = (double**)calloc(outNode,sizeof(double*));
			
		for(i=0 ; i<outNode ; i++)
		{
			who[i] = (double*)calloc(hidNode,sizeof(double));		
		
		}
		for(i=0 ; i<outNode ; i++)
		{
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
			}
		}
		fclose(f1);
   		
      		
   		/********DYNAMIC MEMORY ALLOCATION FOR THE TRAINING DATA*****************************/
   		
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
	
		/*doutTrn = (double *)calloc(outNode,sizeof(double));	*/
			
				
		break;
/******************************************************************************************************************************/	
		
	case 3: 
		
		
		/*********DYNAMIC MEMORY ALLOCATION FOR THE WEIGHT ARRAY*********/
   		
   		f1 = fopen("/user1/home/brojo/100000_run2/wih18","r");
		if(f1==NULL)
			printf("severe ERROR");
		fscanf(f1,"%d %d %lf",&inpNode,&hidNode,&n);
		
		wih = (double**)calloc(hidNode,sizeof(double*));
			
		for(i=0 ; i<hidNode ; i++)
		{
			wih[i] = (double*)calloc(inpNode,sizeof(double));		
		
		}
		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{				
				fscanf(f1,"%lf",&wih[i][j]);				
			}			
		}
		
		fclose(f1);
		
		f1 = fopen("/user1/home/brojo/100000_run2/who18","r");
		
		fscanf(f1,"%d %d %lf",&hidNode,&outNode,&n);		
		
		who = (double**)calloc(outNode,sizeof(double*));
			
		for(i=0 ; i<outNode ; i++)
		{
			who[i] = (double*)calloc(hidNode,sizeof(double));		
		
		}
		for(i=0 ; i<outNode ; i++)
		{
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
			}
		}
		fclose(f1);
   		
      		
   		/********DYNAMIC MEMORY ALLOCATION FOR THE TRAINING DATA*****************************/
   		
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
	
		/*doutTrn = (double *)calloc(outNode,sizeof(double));	*/
			
				
		break;
/*****************************************************************************************************************************/
		
	case 4: 
		
		/*********DYNAMIC MEMORY ALLOCATION FOR THE WEIGHT ARRAY*********/
   		
   		f1 = fopen("/user1/home/brojo/cluster5_21/wih133","r");
		if(f1==NULL)
			printf("severe ERROR");
		fscanf(f1,"%d %d %lf",&inpNode,&hidNode,&n);
		
		wih = (double**)calloc(hidNode,sizeof(double*));
			
		for(i=0 ; i<hidNode ; i++)
		{
			wih[i] = (double*)calloc(inpNode,sizeof(double));		
		
		}
		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{				
				fscanf(f1,"%lf",&wih[i][j]);				
			}			
		}
		
		fclose(f1);
		
		f1 = fopen("/user1/home/brojo/cluster5_21/who133","r");
		
		fscanf(f1,"%d %d %lf",&hidNode,&outNode,&n);		
		
		who = (double**)calloc(outNode,sizeof(double*));
			
		for(i=0 ; i<outNode ; i++)
		{
			who[i] = (double*)calloc(hidNode,sizeof(double));		
		
		}
		for(i=0 ; i<outNode ; i++)
		{
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
			}
		}
		fclose(f1);
   		
      		
   		/********DYNAMIC MEMORY ALLOCATION FOR THE TRAINING DATA*****************************/
   		
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
	
	/*	doutTrn = (double *)calloc(outNode,sizeof(double));			*/
	
					
		break;
/*****************************************************************************************************************************/
		
	case 5: 
		
		/*********DYNAMIC MEMORY ALLOCATION FOR THE WEIGHT ARRAY*********/
   		
   		f1 = fopen("/user1/home/brojo/cluster6_21/wih20","r");
		if(f1==NULL)
			printf("severe ERROR");
		fscanf(f1,"%d %d %lf",&inpNode,&hidNode,&n);
		
		wih = (double**)calloc(hidNode,sizeof(double*));
			
		for(i=0 ; i<hidNode ; i++)
		{
			wih[i] = (double*)calloc(inpNode,sizeof(double));		
		
		}
		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{				
				fscanf(f1,"%lf",&wih[i][j]);				
			}			
		}
		
		fclose(f1);
		
		f1 = fopen("/user1/home/brojo/cluster6_21/who20","r");
		
		fscanf(f1,"%d %d %lf",&hidNode,&outNode,&n);		
		
		who = (double**)calloc(outNode,sizeof(double*));
			
		for(i=0 ; i<outNode ; i++)
		{
			who[i] = (double*)calloc(hidNode,sizeof(double));		
		
		}
		for(i=0 ; i<outNode ; i++)
		{
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
			}
		}
		fclose(f1);
   		
      		
   		/********DYNAMIC MEMORY ALLOCATION FOR THE TRAINING DATA*****************************/
   		
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
	
	/*	doutTrn = (double *)calloc(outNode,sizeof(double));		*/
			
		break;
/***************************************************************************************************************************/
	case 6: 
		
		
   		/*********DYNAMIC MEMORY ALLOCATION FOR THE WEIGHT ARRAY*********/
   		
   		f1 = fopen("/user1/home/brojo/cluster7_21/wih21","r");
		if(f1==NULL)
			printf("severe ERROR");
		fscanf(f1,"%d %d %lf",&inpNode,&hidNode,&n);
		
		wih = (double**)calloc(hidNode,sizeof(double*));
			
		for(i=0 ; i<hidNode ; i++)
		{
			wih[i] = (double*)calloc(inpNode,sizeof(double));		
		
		}
		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{				
				fscanf(f1,"%lf",&wih[i][j]);				
			}			
		}
		
		fclose(f1);
		
		f1 = fopen("/user1/home/brojo/cluster7_21/who21","r");
		
		fscanf(f1,"%d %d %lf",&hidNode,&outNode,&n);		
		
		who = (double**)calloc(outNode,sizeof(double*));
			
		for(i=0 ; i<outNode ; i++)
		{
			who[i] = (double*)calloc(hidNode,sizeof(double));		
		
		}
		for(i=0 ; i<outNode ; i++)
		{
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
			}
		}
		fclose(f1);
   		
      		
   		/********DYNAMIC MEMORY ALLOCATION FOR THE TRAINING DATA*****************************/
   		
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
	
		/*doutTrn = (double *)calloc(outNode,sizeof(double));	*/
			
		break;
/*******************************************************************************************************************************/
	case 7: 
		
		
   		/*********DYNAMIC MEMORY ALLOCATION FOR THE WEIGHT ARRAY*********/
   		
   		f1 = fopen("/user1/home/brojo/cluster8_21/wih160","r");
		if(f1==NULL)
			printf("severe ERROR");
		fscanf(f1,"%d %d %lf",&inpNode,&hidNode,&n);
		
		wih = (double**)calloc(hidNode,sizeof(double*));
			
		for(i=0 ; i<hidNode ; i++)
		{
			wih[i] = (double*)calloc(inpNode,sizeof(double));		
		
		}
		for(i=0 ; i<hidNode ; i++)
		{
			for(j=0 ; j<inpNode ; j++)
			{				
				fscanf(f1,"%lf",&wih[i][j]);				
			}			
		}
		
		fclose(f1);
		
		f1 = fopen("/user1/home/brojo/cluster8_21/who160","r");
		
		fscanf(f1,"%d %d %lf",&hidNode,&outNode,&n);		
		
		who = (double**)calloc(outNode,sizeof(double*));
			
		for(i=0 ; i<outNode ; i++)
		{
			who[i] = (double*)calloc(hidNode,sizeof(double));		
		
		}
		for(i=0 ; i<outNode ; i++)
		{
			for(j=0 ; j<hidNode ;j++)
			{
				fscanf(f1,"%lf",&who[i][j]);
			}
		}
		fclose(f1);
   		
      		
   		/********DYNAMIC MEMORY ALLOCATION FOR THE TRAINING DATA*****************************/
   		
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
	
		/*doutTrn = (double *)calloc(outNode,sizeof(double));	*/
			
		break;
/*******************************************************************************************************************************/	
	default:
		printf("Only eight clusters available\n");
		break;	
	
	
   };/*end switch*/
   
   
  
	
	return;
}
/***********************************************************************/


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
				return_value = 0;
			}
			if((amaxInd == 0) && (dmaxInd == 0))
			{
				tp++;
				return_value = 1;
			}
			if((amaxInd == 1) && (dmaxInd == 0))		
			{
				fn++;
				return_value = 2;
			}
			if((amaxInd == 1) && (dmaxInd == 1))
			{
				tn++;
				return_value = 3;
			}				
		
		}
		printf("\n The testing misclassification....%d",misTst);
		printf("\n The pixels negative but giving positive...%d",fp);
		printf("\n The pixels positive and giving positive...%d",tp);
		printf("\n The pixels positive but giving negative...%d",fn);
		printf("\n The pixels negative and giving negative...%d",tn);
		
		
		
		return(return_value);
	
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
