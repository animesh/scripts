%% run time figure

loglog([1 10 100 1000 10000 100000],[64/60 104/60 129/60 141/60 8 111],'b-o')
hold on
loglog([1 10 100 1000 10000 100000],[90.8/60 102.4/60 103.8/60 138.7/60 48 144],'r-o') % waiting for original results
title('COMET: Running Time')
xlabel('# Spectra');
ylabel('# Minutes');
legend('Classic','Spark','Location','NorthWest')
hold off
print('RunTime','-djpeg')


%% Score bar
addpath('C:\Users\animeshs\SkyDrive\matlab_toolbox')
clear Y
Y(:,:,1) = log10([0 0; 8 8; 73 73; 689 689;9217 9217;78638 78638]); % common
Y(:,:,2) = log10(([0 1; 1 1; 13 17; 123 159;0 0;0 0]))./10; % unique
%Y(:,:,1) = [0 0; 8 8; 73 73; 689 689]; % common
%Y(:,:,2) = [0 1; 1 1; 13 17; 123 159]; % unique
%bar([x;y],'stacked')
%Y = round(rand(5,2,2)*10);
%Y(1:5,1:2,1) = 0; % setting extra zeros to simulate original groups.
groupLabels = { 1, 10, 100, 1000, 10000, 100000 };     % set labels
plotBarStackGroups(Y, groupLabels); % plot groups of stacked bars
title('Top Ranking Peptide Per Spectra; Classic and Spark based COMET algorithm')
xlabel('Number of spectra searched');
ylabel('# Peptide Matches [Log10]');
legend('#common','#unique','Location','NorthWest');
print('ScorePerf','-djpeg')


%% CPU variation
plot(1:1000,-log(1:1000),'k.') % simulated
title('Spark performance over CPU')
xlabel('#cpu');
ylabel('#time');
print('CPUperf','-djpeg')


