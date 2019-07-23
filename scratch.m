%
% perform a quick sanity check
%

uint64(4)  + uint64(2)
uint64(4)  - uint64(2)
uint64(4) ./ uint64(2)
uint64(4) .* uint64(2)

%% read
prot=xlsread('L:\Elite\LARS\2014\juni\Pseudomonas\PesudoSproteinGroups.xls');
prot=prot(:,5:8);

%% check
plot(prot)
histfit(prot(~isnan(prot)))


data=dataset('XLSFile','L:\Results\Ishita\Log2abs0.5.xlsx');
load bc_train_filtered
bcTrainData
load bc_proggenes231
[tf, idx] = ismember(bcProgGeneList.Accession, bcTrainData.Accession);
progValues = bcTrainData.Log10Ratio(idx, :);
progAccession = bcTrainData.Accession(idx);
progSamples = bcTrainData.Samples;
progValues = str2double(dataset2cell(data(:,8:19)));
progAccession = dataset2cell(data(:,1));
progSamples = dataset2cell(data(1,8:19));
cg_s = clustergram(progValues, 'RowLabels', progAccession,...
                                 'RowPdist', 'correlation',...
                                 'ColumnPdist', 'correlation',...
                               'Colormap', 'parula',...
                               'ImputeFun', @knnimpute)
cg_s = clustergram(progValues, 'RowLabels', progAccession,...
                               'ColumnLabels', progSamples,...
                                 'RowPdist', 'correlation',...
                                 'ColumnPdist', 'correlation',...
                               'Colormap', 'parula',...
                               'ImputeFun', @knnimpute)

