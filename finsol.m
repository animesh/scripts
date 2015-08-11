%% sqrt newton method

x=1;
for k=1:10
     x=x-(x^2-2)/(2*x) 
end

x=linspace(-10,0.1,10); 
                      
plot(x,x.^2,2*x,(x.^2)/(2*x))


%% secant method

clear x
x(1)=1
x(2)=x(1)+rand(x(1))
for k=2:5
     x(k+1)=x(k)-(x(k)^2-2)*(x(k)-x(k-1))/(x(k)^2-2-x(k-1)^2+2)
end
plot(x,x.^2-2,'r-')

%% check logical operator
j=10000
for i=1:j
    l(i)=(0.0001*i==i/j);
end
sum(l)

%% source

http://ocw.mit.edu/courses/mathematics/18-s997-introduction-to-matlab-programming-fall-2011/root-finding/newtons-method/
http://ocw.mit.edu/courses/mathematics/18-s997-introduction-to-matlab-programming-fall-2011/root-finding/the-secant-method/
http://ocw.mit.edu/courses/mathematics/18-100a-introduction-to-analysis-fall-2012/readings/MIT18_100AF12_Assign_1.pdf

