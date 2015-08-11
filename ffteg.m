%% motivated by http://grasshoppernetwork.com/showthread.php?tid=629
%% create signal
a=5;
c=1;
m=2;
f=50;
n=10;%no of sample per second?
fs=100*f;% @least twice by nequist
ts=1/fs;
t=0:ts:n/f;
x = c+a*sin(2*pi*f*t)+a*sin(2*pi*m*f*t)+a*sin(2*pi*2*m*f*t);
plot(x);
fx=fft(x);
plot(real(fx))
[idx val]=max(real(fx))


%% orig
f=50;
A=5;
Fs=f*100;
Ts=1/Fs;
t=0:Ts:10/f;
x=A*sin(2*pi*f*t);
plot(x),grid on;
F=fft(x);
plot(real(F)),grid on
[idx val]=max(real(F))

%% mix signal
x1=A*sin(2*pi*(f+50)*t);
x2=A*sin(2*pi*(f+250)*t);
x=x+x1+x2; 
F=fft(x);
plot(real(F)),grid on
[idx val]=max(real(F))

%% extract main 
F2=zeros(length(F),1);
F2(10:11)=F(10:11);
xr=ifft(F2);
plot(real(xr)),grid on

%% recreate
clear all;
clc;
close all
f=50;
A=5;
Fs=f*100;
Ts=1/Fs;
t=0:Ts:10/f;
x=A*sin(2*pi*f*t);
x1=A*sin(2*pi*(f+50)*t);
x2=A*sin(2*pi*(f+250)*t);
x=x+x1+x2;
plot(x)
F=fft(x);
figure
N=Fs/length(F);
baxis=(1:N:N*(length(x)/2-1));
plot(baxis,real(F(1:length(F)/2))) 

