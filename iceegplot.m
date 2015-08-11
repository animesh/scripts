%% read data
d=load('C:\Users\animeshs\SkyDrive\chum\Sample.mat')
[r c]=size(d.d)
plot(d.d(r,:))

%% check
plot(d.d(1:50,:))
autocorr(d.d(r,:)')

%% symbolic test

% source http://blogs.mathworks.com/loren/2012/07/27/using-symbolic-equations-and-symbolic-functions-in-matlab/?s_eid=PSM_1986

besselODE = 't^2*D2y+t*Dy+(t^2-n^2)*y';
f = dsolve(besselODE,'y(1)=1','y(2)=n','t');
pretty(f)


%% RBM's:http://code.google.com/p/matrbm/

%train an RBM with binary visible units and 500 binary hidden
model= rbmBB(d, 500);

%visualize the learned weights
visualize(model.W);

% Do classification:

model= rbmFit(data, 500, labels);
prediction= rbmPredict(model, testdata);

%Train a Deep Belief Network with 500,500,2000 architecture for classification:

models= dbnFit(data, [500 500 2000], labels);
prediction= dbnPredict(models, testdata);

