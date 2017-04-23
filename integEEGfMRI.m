%% simulate fMRI
a=0;
b=1000;
alpha=-2/3;
n=rand(1000000,1)';
r=(a.^(alpha+1)+n*(b^(alpha+1)-a.^(alpha+1))).^(1/(alpha+1));
plot(n,r,'.');
hist(n);
hist(r);

%% simulate EEG
a=0;
b=1000;
alpha=-2/3;
n=rand(1000000,1)';
r=(a.^(alpha+1)+n*(b^(alpha+1)-a.^(alpha+1))).^(1/(alpha+1));
plot(n,r,'.');
hist(n);
hist(r);
