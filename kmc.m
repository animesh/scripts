p = [ 1 1; 2 1; 4 3; 5 4]
clus = 2
c=zeros(size(p))
[R, C]=size(p);
if R<=clus, 
    mp=[p, 1:R];
else
    p = randperm(size(p,2));  
    for i=1:clus
        c(i,:)%=p(p(i),:); 
    end
end
g=
temp=zeros(R,1);
f=size(p,2)
while f<1
        d=dist(p);
        [z,g]=min(d,[],2);
        for i=1:clus
            f=find(g==i);
        end
        f=f-1
end
p,g


%% Causal test

u=rand(100,1)
y=rand(100,1)
m=1
n=m
plot(u,y,'r.')

N = length(y);

thy_u = arx([y,u],[m, m, 0]);
thy = ar(y, m,'ls');
S1y=thy_u(1,1);
S2y=thy(1,1);

F1 = (N-2*m)*(S2y-S1y)/m/S1y;
Pf1=fpdf(F1,m,m);

thu_y = arx([u,y],[n, n, 0]);
thu = ar(u, n,'ls');
S1u=thu_y(1,1);
S2u=thu(1,1);

F2 = (N-2*n)*(S2u-S1u)/n/S1u;
Pf2=fpdf(F2,n,n);

if ~nargout
   if F2>F1
      disp('The second argument causes the first one.')
   else
      disp('The first argument causes the second one.')
   end
end


%% source
http://www.nbtwiki.net/doku.php?id=tutorial:tutorial_sync:background#.UWvSIHe9D6k
http://planetorbitrap.com/data/uploads/ZFS1317331519767_ASMS11_M093_OLange_H.pdf
http://www.its.caltech.edu/~daw/teach/matlab4ephys.pdf
http://en.wikipedia.org/wiki/Cross-validation_%28statistics%29