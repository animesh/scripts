%% data

x=[220.22 223.54      1.00
223.84 237.44      1.00
258.32 287.93      0.00
241.53 267.49      1.00
241.79 281.38      1.00
253.21 280.85      1.00
256.95 292.47      0.00
209.14 207.97      1.00
251.28 290.98      0.00
246.40 283.78      1.00
240.18 290.06      0.00
239.29 274.88      1.00
239.76 284.66      0.00
230.33 251.00      1.00
227.93 236.58      1.00
244.40 277.28      1.00
254.29 287.09      0.00
249.64 287.16      0.00
249.42 278.21      1.00
234.42 260.52      1.00
244.10 290.09      0.00
254.66 297.62      0.00
255.67 283.95      0.00
258.01 280.69      1.00
235.12 271.74      1.00]

%% check

plot(x(:,1),x(:,2),'r.')
plot3(x(:,1),x(:,2),x(:,3),'r.')
plot(x(x(:,3)==0,1),x(x(:,3)==0,2),'r.')
hold
plot(x(x(:,1)==0,1),x(x(:,3)==1,2),'b.')
plot(x(x(:,3)==0,1),x(x(:,3)==1,2),'b.')
plot(x(x(:,3)==1,1),x(x(:,3)==1,2),'b.')
plot(x(x(:,3)==0,1),x(x(:,3)==0,2),'r.')
[b,dev,stats] = glmfit(x(:,1:2),x(:,3),'binomial','logit')
svmStruct = svmtrain(train,class,'showplot',true,'KERNEL_FUNCTION','polynomial','POLYORDER',2);
svmStruct = svmtrain(x(:,1:2),x(:,3),'showplot',true,'KERNEL_FUNCTION','polynomial','POLYORDER',2);
svmStruct = svmtrain(x(:,1:2),x(:,3),'showplot');
svmStruct = svmtrain(x(:,1:2),x(:,3),'showplot','true');
svmStruct = svmtrain(x(:,2),x(:,3),'showplot','true');
svmStruct = svmtrain(x(:,2:2),x(:,3),'showplot','true');
svmStruct = svmtrain(x(:,2:2),x(:,3));
svmStruct = svmtrain(x(:,2),x(:,3));
help svmStruct
help svmtrain
svmStruct = svmtrain(x(:,2),x(:,3));
help svmtrain
C = svmclassify(svmStruct,x(:,2),'showplot',true);
C = svmclassify(svmStruct,x(:,2))
plot(C,x(:3))
plot(C(:),x(:3))
plot(C(:),x(:,3))
plot(C(:),x(:,3),'b.')
sum(C(:)-x(:,3))
svmStruct = svmtrain(x(:,2),x(:,3))
svmStruct = svmtrain(x(:,1:2),x(:,3),'showplot',true,'KERNEL_FUNCTION','polynomial','POLYORDER',1);
svmStruct = svmtrain(x(:,1:2),x(:,3),'showplot',true,'KERNEL_FUNCTION','polynomial','POLYORDER',4);
svmStruct = svmtrain(x(:,1:2),x(:,3),'showplot',true,'KERNEL_FUNCTION','polynomial','POLYORDER',3);
C = svmclassify(svmStruct,x(:,1:2),'showplot',true)
C = svmclassify(svmStruct,x(:,1:2),'showplot','true')
sum(C(:)-x(:,3))
svmStruct = svmtrain(x(:,1:2),x(:,3),'showplot',true,'KERNEL_FUNCTION','polynomial','POLYORDER',6);
svmStruct = svmtrain(x(:,1:2),x(:,3),'showplot',true,'KERNEL_FUNCTION','polynomial','POLYORDER',1);

%% class

class = classify(x(:,1:2),x(:,1:2),x(:,3),'mahalanobis')
sum(class(:)-x(:,3))
