%% read file and info
all=sffread('Ecoli.sff')
info = sffinfo('Ecoli.sff')

%% plot
len = cellfun(@length, {all(:).Sequence});
meanLength = mean(len)
medianLength = median(len)
stdLength = std(len)

figure(); hist(len);
xlabel('Sequence length');
ylabel('Number of reads');
title('Length distribution');

%=== metrics on the quality
qual = double([all.Quality]);
meanQuality = mean(qual)
medianQuality = median(qual)
stdQuality = std(qual)

figure(); hist(qual);
xlabel('Quality Score');
ylabel('Number of reads');
title('Quality score distribution')
