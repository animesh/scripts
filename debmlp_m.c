/* this is a simple implementation of a MLP with a single hidden layer,
this was written for a MLP as a classifier, but it will work with all kinds of data provided the outputs are normalized i.e. lie between [0,1]*/
 
#include<stdio.h>
#include<math.h>
#include<stdlib.h>
#include<time.h>

#define THRES 0.001

float **data;
float **target;

float *output2;
float *input2;
float *output3;
float *output4;
float **weight12;
float **weight23;
   float *error;
   float *delta2;

int nDim;
int nData;
int nClass;

int nHiddenUnits;
unsigned int Seed;

float eta=0.01;

int iter;

void readData()
{ int i,j;
  char dataFileName[40];
  FILE *fp;

   printf(" Enter the number of data points\n");
   scanf("%d",&nData);

   printf(" Enter the number of dimensions\n");
   scanf("%d",&nDim);

   printf(" Enter the number of classes\n");
   scanf("%d",&nClass);

   Seed = (unsigned int)time(NULL);

   printf(" Enter number of iterations \n");
   scanf("%d",&iter);

   printf("Enter the data file name:\n");
   scanf("%s",dataFileName);

   fp = fopen(dataFileName,"r");

     if(fp==NULL)

         {  printf("cannot open file %s",dataFileName);

            exit(0);
         }

     data = (float**)malloc(nData*sizeof(float*));

        for( i = 0; i < nData; i++)
                { data[i] = (float*)malloc(nDim*sizeof(float));

                   if(data[i]==NULL){ printf("Memory allocation failed\n");
                                      exit(0);
                                    }
                }
        target = (float**)malloc(nData*sizeof(float*));

        for( i = 0; i < nData; i++)
                { target[i] = (float*)malloc(nClass*sizeof(float));

                   if(target[i]==NULL){ printf("Memory allocation failed\n");
                                        exit(0);
                                      }
                }


   for(i=0;i<nData;i++)
     { for(j = 0;  j < nDim; j++) 
          fscanf(fp,"%f",&data[i][j]);

       for(j = 0; j < nClass; j++)
          fscanf(fp,"%f",&target[i][j]);
     }

   fclose(fp);

   printf("Data Read \n");

  printf("No of hidden units\n");
  scanf("%d",&nHiddenUnits);

 printf("enter eta\n");
 scanf("%f",&eta);
}
 

void initialization()
{  int i,k;
   time_t t;
 
  /* initializing weight matrix */

   weight23 = (float **)malloc(nClass*sizeof(float*));
   weight12 = (float **)malloc(nDim*sizeof(float*));

        for( i = 0; i < nClass; i++)
                { weight23[i] = (float*)malloc(nHiddenUnits*sizeof(float));

                   if(weight23[i]==NULL){ printf("Memory allocation failed for weight\n");
                                        exit(0);
                                      }
                }

        for( i = 0; i < nDim; i++)
                { weight12[i] = (float*)malloc(nHiddenUnits*sizeof(float));

                   if(weight12[i]==NULL){ printf("Memory allocation failed for weight\n");
                                        exit(0);
                                      }
                }

   rand((long int)time(&t));


   for(i = 0; i < nClass ; i++)
     for(k = 0; k < nHiddenUnits; k++)
         /*weight23[i][k] = -0.5 + ((rand()%987791)/987791.0) ;*/
         weight23[i][k] =  -0.5 + drand48();

  /*  Patch */
  /* for(i = 0; i < nClass ; i++)
     { for(k = 0; k < nHiddenUnits; k++)
          printf("%f ", weight23[i][k]);
            printf("\n");
      }

    exit(0);*/
  /*  Patch */
      
   for(i = 0; i < nDim ; i++)
     for(k = 0; k < nHiddenUnits; k++)
         /*weight12[i][k] = -0.5 + ((rand()%987791)/987791.0) ;*/
         weight12[i][k] =  -0.5 + drand48();

   /* allocating memory for output2 */
 
   output2  = (float *)malloc(nHiddenUnits*sizeof(float*));
   input2  = (float *)malloc(nHiddenUnits*sizeof(float*));

  /* allocating memory for output3 */

   output3 = (float *) malloc(nClass * sizeof(float));

  error = (float *)malloc(nClass * sizeof(float));



   delta2 = (float *) malloc(nHiddenUnits*sizeof(float));

 /* end initialization */

printf("initializationDone \n");
}

float calculateOutput2( hiddenUnitID, dataID)
 int hiddenUnitID;
 int dataID;

{ int i,j;
  float out,temp =0;

   for(i=0;i<nDim;i++)
      temp = temp + weight12[i][hiddenUnitID]* data[dataID][i];/*atten[n];*/

   out = 1/(1 + (float)exp(-temp));

  return(out);
}



float calculateOutput3(classID)
int classID;
{ int i,k;
  float out=0,out1;


    for( k = 0; k < nHiddenUnits ; k++)
      out = out + weight23[classID][k] * output2[k];

  out1 = 1/(1 + (float)exp(-out));

  return(out1);
} 


forward(dataNo)
int dataNo;

{ int i,j,l,k;
  float temp;


      for (k = 0; k < nHiddenUnits; k++)
           output2[k] = calculateOutput2(k,dataNo);
      

        for( i = 0; i < nClass; i++)
             output3[i] = calculateOutput3(i);
}


void learning()
{  int i,j,k,l;
   int iterNo=0,dataID;
   float squareError;
   float extra;
   void misClass(void);


 while(iterNo < iter)
  { 

 squareError =0;
    
  if(iterNo%1==0)
   {
    for( dataID = 0; dataID < nData; dataID++)
     { forward(dataID);
         for(i = 0; i < nClass; i++)
            squareError = squareError + (output3[i]-target[dataID][i]) *(output3[i]-target[dataID][i]);
     }
       printf("SSE after iteration %d is %f\n",iterNo,squareError);
       misClass();
       squareError =0;
    } 



   for( dataID = 0; dataID < nData; dataID++)
     { forward(dataID);

       for( k = 0; k < nHiddenUnits; k++)
            delta2[k] = 0.0;

        for( i = 0; i < nClass; i++)
           error[i] = output3[i] - target[dataID][i];

        
    
       /* Weight updation */

        for( i = 0; i < nClass; i++)
            for( k = 0; k < nHiddenUnits; k++)
                weight23[i][k] = weight23[i][k] - eta * error[i] * output2[k]*output3[i]*(1-output3[i]);


           for(k = 0; k < nHiddenUnits; k++)
                for( i = 0; i < nClass; i++) 
                      delta2[k] +=  error[i] * weight23[i][k]*output3[i]*(1-output3[i]);


            for(i=0; i< nDim; i++)
                for(j=0;j<nHiddenUnits;j++)
                  weight12[i][j] = weight12[i][j] - eta * delta2[j]*data[dataID][i]*(1-output2[j])*output2[j]; 
     
       
     }
    /*  printf("%%%%%%%% Done for all data %%%%%%%%%%%%%%%%%%%\n");*/

 /* squareError =0;
     
  if(iterNo%1==0)
   { 
    for( dataID = 0; dataID < nData; dataID++)
     { forward(dataID);
         for(i = 0; i < nClass; i++)
            squareError = squareError + (output3[i]-target[dataID][i]) *(output3[i]-target[dataID][i]);
     }
       printf("SSE after iteration %d is %f\n",iterNo,squareError);
       squareError =0;
    } */

   iterNo++;

  }
}

void  misClass()    
{ int i, nMisClass=0, label=0,dataNo;
  float max=0;

   for(dataNo=0; dataNo < nData; dataNo++)
     { forward(dataNo);
        for(i=0; i< nClass; i++)
          {if(output3[i]>max){ max = output3[i];
                              label = i;
                            }
          }

      if(target[dataNo][label]!=1) nMisClass++;
      max =0; label =0;
     }

  printf("Misclassification = %d\n", nMisClass);
}

void toTest()
{ int i,j,k;
  char choice[10], fileNam[30];
  FILE *fpTest;

  printf("Want to test?yes/no\n");
  scanf("%s",choice);

  if(strcmp(choice,"yes")==0)
  {  printf("input testDataFile\n");
     scanf("%s",fileNam);
     
     fpTest = fopen(fileNam,"r");

      if(fpTest==NULL){printf("cannot open file %s\n");
                       exit(0);
                      }
     for(i=0;i<nData;i++)
      { free(data[i]);
        free(target[i]);
      }
       free(data);
       free(target);
    
    printf("enter no of test data points\n");
    scanf("%d",&nData);
    printf("scanned\n");

    printf("Allocating memory----\n");
           
       data = (float**)malloc(nData*sizeof(float*));

        for( i = 0; i < nData; i++)
                { data[i] = (float*)malloc(nDim*sizeof(float));

                   if(data[i]==NULL){ printf("Memory allocation failed\n");
                                      exit(0);
                                    }
                }
        target = (float**)malloc(nData*sizeof(float*));

        for( i = 0; i < nData; i++)
                { target[i] = (float*)malloc(nClass*sizeof(float));

                   if(target[i]==NULL){ printf("Memory allocation failed\n");
                                        exit(0);
                                      }
                }
     printf("          allocated\n");

printf("reading data ---- \n");
   for(i=0;i<nData;i++)
     { for(j = 0;  j < nDim; j++)
          fscanf(fpTest,"%f",&data[i][j]);

       for(j = 0; j < nClass; j++)
          fscanf(fpTest,"%f",&target[i][j]);
     }
   fclose(fpTest);
   printf("          read\n");
 
   printf("Misclassification on test data");
    misClass();
  }
}
    
main()
{ int i,j;

  readData();
  initialization();
  learning();
  printf("training terminated\n");
  printf("Misclassification on training Data\n");
  misClass();
   toTest(); 

}  
