%% simulate power law from uniform
a=0;
b=1000;
alpha=-2/3;
n=rand(1000000,1)';
r=(a.^(alpha+1)+n*(b^(alpha+1)-a.^(alpha+1))).^(1/(alpha+1));
plot(n,r,'.');
hist(n);
hist(r);
    
%% create samples and species count
sampN=4;
specN=10;
ssc=zeros(sampN,specN);
for i=1:sampN
    % sample
    m=i*1000;
    sample = r(:,randperm(m));
    hist(sample);
    for j=1:specN
        %similarity search
        similar = j*size(n',1)/(m*100);
        idx = [logical(1) diff(sample)>similar];
        sampleReduced = sample(idx);
        hist(sampleReduced);
        ssc(i,j) = size(sampleReduced',1);
    end
end
plot(ssc)
