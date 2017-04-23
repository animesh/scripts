%% load data
%load('svm_mat555');

%% extract zone
data_STS=svm_mat(:,ind_STS,:);

%% plot zone
temp=data_STS(7,round(33.0078),:);
temp=Design_Para(:,1);
plot(squeeze(temp));
axis equal;axis off;
plot(Design_Para(:,4))
hold
plot(Design_Para(:,6),'r')
hold off

%% Extract musicness
[s v t]=size(svm_mat);
temp=reshape(svm_mat,s*v,t);
time1=Design_Para(:,4)';
temp=[temp;time1];
temp=temp';
save('musicness.txt','temp','-ascii','-tabs');

%% check reshape with temp
temp=zeros(2,3,4)
%[s v t]=size(svm_mat);
[s v t]=size(temp)
for i = 1:s
for j = 1:v
for k = 1:t
        temp(i,j,k)=(i*100+10*j+k)
        end
    end
end
temp=reshape(temp,s*v,t);
time1=1:4
temp=[temp;time1]


%% save file
save('a.txt','a','-ascii','-tabs');

%% run perl
system('perl tab2csv.pl a.txt.csv');

%% run weka
system('export CLASSPCLASSPATHATH=$CLASSPATH:/media/DATA');
setenv('CLASSPATH', '/media/DATA' );
system('java weka.classifiers.functions.MultilayerPerceptron -t a.txt.csv');

publish;

