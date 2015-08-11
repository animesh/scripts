%% read file
filename='Ecoli.sff';
%M = 100;
%sf = sffread(filename, 'block', [1 M], 'feature', 'f')
%all = sffread(filename, 'block', [1 M], 'feature', 'sqc');
sf = sffread(filename, 'feature', 'hf');

%% extract flow

x=rand(1,10)
sf10=sf(1).FlowgramValue(:);
sfh10=sfh(1).Header(:)'

for i 1:10
    blastval(i)=[sfh(i).Header(:)',x(i)']
end