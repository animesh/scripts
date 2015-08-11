%% kernel projection demo

datac0=[rand(10,1);-rand(10,1)];
plot(datac0,0,'r.')
datac1=[randi(10,10,1)',-randi(10,10,1)']';
hold
plot(datac1,0,'b.')
hold off
train=[datac0;datac1]


figure
class=[zeros(20,1);zeros(20,1)+1];
train2d=[train,train.*train]
svmStruct = svmtrain(train2d,class,'showplot',true);


%% svm circle polykernel with order 2
i = 1;
a = 0;
b = 20;
p=100;
c=0;
circle=zeros(p,2);
rect=zeros(p,2);
while i <= p
    c=c+1;
    x1 = a + (b-a).*rand();
    x2 = a + (b-a).*rand();
    r1 = (a+b)/2;
    r2 = (a+b)/2;
    d=((r1-x1).^2+(r2-x2).^2).^(1/2);
    if d < ((a+b)/4)
        circle(i,1)=x1;
        circle(i,2)=x2;
        i=i+1;
    else
        rect(i,1)=x1;
        rect(i,2)=x2;
    end

end

plot(circle(:,1),circle(:,2),'r.')
hold
plot(rect(:,1),rect(:,2),'b.')
hold off

train=[circle;rect];
class=[zeros(p,1);zeros(p,1)+1];


figure
svmStruct = svmtrain(train,class,'showplot',true,'KERNEL_FUNCTION','polynomial','POLYORDER',2);

