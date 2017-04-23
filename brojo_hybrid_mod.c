/*******************************************************************************/
#include<stdio.h>
#include<stdlib.h>
#include<math.h>

/*******************************************************************************/
int 	noNN,NN,inpNode,hidNode,outNode,epoc=0,iter=0;
int	i,t,j,k,fp=0,tp=0,tn=0,fn=0,modify,i_test,j_test;
long 	cntTrnData=0,misTst=0,cntTstData=1,Misclsf = 0,cntTstData_ori=0;
int	ch,misc=0,amaxInd,dmaxInd;
double 	**wih,**who,**pwih,**cwih,**pwho,**cwho,**trnData,**tstData;
double	**aoutput,*delta_inp;
double	sse=0,prevsse=0,n=.9;
double 	**err,**aoutput2,*outdelta;
double	*netValHid,*hidActiv,*netValOup,*doutTrn,*outActiv,**doutTst,d;
double	**wih1,**who1,**clsCntr;
double 	*fOut,*pfOut,*fOut1;
double 	eDis,sumGate,*max,*min;
char	file[50],file1[50];

FILE 	*fr,*fw;
char 	trainingfile[50],testingfile[60],statusfile[50],ihfile[50],hofile[50],*index;

double *iv;

void initialize(int);
int testing(double *);
double sigmoid(double);		
double distance(int);
		
FILE *cluster_cen;
FILE *fout;
int out,noofcluster;
/************************************************************************************************************************/
void main()
{
	
	double dist,dist1;
	int cluster_index,ret;
	
	fout=fopen("output.txt","w");
	fclose(fout);
	
	cluster_cen=fopen("cluster_put21.txt","w");
	fclose(cluster_cen);
	
	printf("Enter the iname of input test file: ");
	scanf("%s",testingfile);
	
	printf("Length of input vector: ");
	scanf("%d",&inpNode);
	
	printf("Length of output vector: ");
	scanf("%d",&outNode);
	
	printf("Number of Clusters: ");
	scanf("%d",&noofcluster);
	
	iv=(double*)calloc(inpNode+outNode,sizeof(double));
	
		
	strcpy(file1,"centers.txt");
	
	fr = fopen(testingfile,"r");
	
	while(!feof(fr))
	{
		if((ch=getc(fr))=='\n')
			cntTstData_ori++;
			
	}
	fclose(fr);
	
	printf("\nTest Data = %d\n",cntTstData_ori);
	
	/******************DYNAMIC MEMORY ALLOCATION TO STORE THE CLUSTER CENTERS************/
	
	clsCntr = (double**)calloc(noofcluster,sizeof(double*));
	if(clsCntr == NULL)
	{
		printf("\n Error in clsCntr\n");
		exit(0);
	}
		
	for(i=0 ; i<noofcluster ; i++)
	{
		clsCntr[i] = (double*)calloc(inpNode,sizeof(double));
		
		if(clsCntr[i] == NULL)
		{
			printf("\n Error in clsCntr's\n");
			exit(0);
		}
	}	
	
	/*********READING THE CLUSTER CENTERS**********/
	
	FILE *f1=fopen(file1,"r");
	for(i=0 ; i<noofcluster ; i++)
	{
		for(j=0 ; j<inpNode ; j++)
		{
			fscanf(f1,"%lf",&clsCntr[i][j]);
			
		}
	}
	fclose(f1);
	
	
	
	/*for(i=0 ; i<noofcluster ; i++)
	{
		for(j=0 ; j<inpNode ; j++)
		{
			printf("%16.15lf ",clsCntr[i][j]);
			
		}
		printf("\n");
		
	}*/
	
	
	fr = fopen(testingfile,"r");
	
	for(i_test = 0 ; i_test < cntTstData_ori ; i_test++)
	{
		for(j_test = 0 ; j_test <(inpNode+outNode) ; j_test++)
		{
			fscanf(fr,"%lf",&iv[j_test]);
			
		}
		
		dist = distance(0);
		cluster_index = 0;
		for(int p=1;p<noofcluster;p++)
		{
			dist1 = distance(p);
			if(dist1 < dist)
			{
				dist = dist1;
				cluster_index = p;
			}
		}
		
		
		initialize(cluster_index);
		initialize(4);
		ret=testing(iv);			
		
		cluster_cen=fopen("cluster_put21.txt","a");
		
		if((ret==1)&&(out!=1))
		{
			fprintf(cluster_cen,"%d  %d  %d  %d %d\n",i_test,0,1,cluster_index,!out);
		}
		if((ret==0)&&(out!=0))
		{
			fprintf(cluster_cen,"%d  %d  %d  %d %d\n",i_test,1,0,cluster_index,!out);
		}
		fclose(cluster_cen);
	}
	fclose(fr);
	
	
	
}




void 	initialize(int j2)
{
	
	FILE 	*f1,*f2;	
	
	   
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
	
		doutTrn = (double *)calloc(outNode,sizeof(double));		
			
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
	
		doutTrn = (double *)calloc(outNode,sizeof(double));	
			
	
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
	
		doutTrn = (double *)calloc(outNode,sizeof(double));	
			
				
		break;
/******************************************************************************************************************************/	
		
	case 3: 
		
		
		/*********DYNAMIC MEMORY ALLOCATION FOR THE WEIGHT ARRAY*********/
   		
   		f1 = fopen("/user1/home/brojo/cluster4_21/wih168","r");
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
		
		f1 = fopen("/user1/home/brojo/cluster4_21/who168","r");
		
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
	
		doutTrn = (double *)calloc(outNode,sizeof(double));	
			
				
		break;
/*****************************************************************************************************************************/
		
	case 4: 
		
		/*********DYNAMIC MEMORY ALLOCATION FOR THE WEIGHT ARRAY*********/
   		
   		f1 = fopen("/user1/home/brojo/wih100","r");
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
		
		f1 = fopen("/user1/home/brojo/who100","r");
		
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
	
		doutTrn = (double *)calloc(outNode,sizeof(double));			
	
					
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
	
		doutTrn = (double *)calloc(outNode,sizeof(double));		
			
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
	
		doutTrn = (double *)calloc(outNode,sizeof(double));	
			
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
	
		doutTrn = (double *)calloc(outNode,sizeof(double));	
			
		break;
/*******************************************************************************************************************************/	
	default:
		printf("Only four clusters available\n");
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
		
		cntTstData=1;
		for(i = 0 ; i < cntTstData ; i++)
		{
			for(j=0 ; j<outNode; j++)
			{
				doutTst[i][j] = tstData[i][inpNode+j];
				
			}	
		}
		
		
		
		cntTstData=1;	/***********THE following loop will loop once****************/
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
			if((aoutput2[k][0])<aoutput2[k][1])
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
		
		
		out = amaxInd;
		return(dmaxInd);			
			
	
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
