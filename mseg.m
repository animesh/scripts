%% download and install orbitrap to mzxml convertor

wget http://unfinnigan.googlecode.com/files/Finnigan-0.0206.tar.gz
tar xvzf Finnigan-0.0206.tar.gz
cd Finnigan-0.0206/
cpan
install Data::Hexdumper
install CPAN
reload cpan
install Data::Hexdumper
install  Digest::SHA1
install  YAML
install Getopt::Declare
install Module::Find
install Tie::IxHash
install XML::Generator
perl Makefile.PL
make install
uf-rfi 20070522_NH_Orbi2_HelaEpo_01.RAW
uf-rfi  20070522_NH_Orbi2_HelaEpo_02.RAW
uf-meth 20070522_NH_Orbi2_HelaEpo_01.RAW
uf-mzxml -c 20070522_NH_Orbi2_HelaEpo_01.RAW > d1.mzxml
uf-mzxml -c 20070522_NH_Orbi2_HelaEpo_02.RAW > d12.mzxml

%% msviewer example

load sample_lo_res
msviewer(MZ_lo_res, Y_lo_res)

plot(Y_lo_res(:,2))
hold
plot(Y_lo_res(:,1),'r.')
hold off
clear MZ_lo_res Y_lo_res;

%% Read MS mzxml from HeLa grown in SILAC Arg10/Lys8 (Heavy) and without (Light) under EGF for 2 hours, combined and lysed with Trypsin and fractioned in 24 parts using isoelectric focussing (PI based fractions, MS with CID in ion trap)

out = mzxmlread('d1.mzxml');
out2 = mzxmlread('d12.mzxml');

%% heatmaps of MS spectra, log intensity as colors http://www.mathworks.se/help/bioinfo/examples/differential-analysis-of-complex-protein-and-metabolite-mixtures-using-liquid-chromatography-mass-spectrometry-lc-ms.html

[ps,ts] = mzxml2peaks(out,'level',1);
[pg,tg] = mzxml2peaks(out2,'level',1);
[MZs,Ys] = msppresample(ps,5000);
[MZg,Yg] = msppresample(pg,5000);

fh1 = msheatmap(MZs,ts,log(Ys),'resolution',0.15);
title('HeLa, SILAC+EGF, Fraction 1')
fh2 = msheatmap(MZg,tg,log(Yg),'resolution',0.15);
title('HeLa, SILAC+EGF, Fraction 2')

% Picking out specific regions in the MS spectra
ind_ser = samplealign(ts,[2000;4000]);
figure(fh1);
axis([300 600 ind_ser'])
ind_gly = samplealign(tg,[2000;4000]);
figure(fh2);
axis([300 600 ind_gly'])


%% lag between two fractions

whos('Ys','Yg','ts','tg')
plot(1:numel(ts),ts,1:numel(tg),tg)
legend('Frc 1','Frc 2','Location','NorthWest')
title('Time Vectors of the LCMS Data Sets')
xlabel('Spectrum Index')
ylabel('Retention Time (seconds)')


%% stem3 example http://www.mathworks.se/help/bioinfo/examples/visualizing-and-preprocessing-hyphenated-mass-spectrometry-data-sets-for-metabolite-and-protein-peptide-profiling.html

msdotplot(ps,ts,'quantile',.95) % check high intensity peaks
title('5 Percent Overall Most Intense Peaks')

numScans = numel(ps)
basePeakInt = [out.scan.basePeakIntensity]';
peaks_fil = cell(numScans,1);

for i = 1:numScans
    h = ps{i}(:,2) > (basePeakInt(i).*0.75);
    peaks_fil{i} = ps{i}(h,:);
end

msdotplot(peaks_fil,ts) % not working?

% too slow for whole

peaks_3D = cell(numScans,1);
for i = 1:numScans
peaks_3D{i}(:,[2 3]) = peaks_fil{i};
peaks_3D{i}(:,1) = ts(i);
end
peaks_3D = cell2mat(peaks_3D);

figure(fh2);

stem3(peaks_3D(:,1),peaks_3D(:,2),peaks_3D(:,3),'marker','none')

axis([0 12000 400 1500 0 1e9])
view(60,60)
xlabel('Retention Time (seconds)')
ylabel('Mass/Charge (M/Z)')
zlabel('Relative Ion Intensity')
title('Peaks Above (0.75 x Base Peak Intensity) for Each Scan')


%% test stem3
numScans=size(Ys,1)
numel(MZs)
numScans=numel(MZs)
peaks_3D = cell(numScans,1);
for i = 1:numScans
peaks_3D{i}(:,[2 3]) = MZs{i};
peaks_3D{i}(:,1) = Ys(i);
end
peaks_3D = cell2mat(peaks_3D);
peaks_3D = cell(numScans,1)
for i = 1:numScans
peaks_3D{i}(:,[2 3]) = MZs{i};
peaks_3D{i}(:,1) = Ys(i);
end



%% plot m z from MS xml http://www.mathworks.se/help/bioinfo/ug/features-and-functions.html#bp4mcvy

plot(out.index.offset.id, out.index.offset.value)
m = out.scan(1).peaks.mz(1:2:end);
z = out.scan(1).peaks.mz(2:2:end);
stem(m,z,'marker','none')
out.scan.peaksCount
m2 = out2.scan(1).peaks.mz(1:2:end);
z2 = out2.scan(1).peaks.mz(2:2:end);
stem(m,z,'MarkerFaceColor','g', 'MarkerSize',2, 'MarkerEdgeColor','k')
hold
stem(m2,z2,'MarkerFaceColor','b', 'MarkerSize',2, 'MarkerEdgeColor','k')
hold off
hist(z2)
hist(m2)
axis equal
[f,xi] = ksdensity(z2); 
plot(xi,f); 
hold
[f,xi] = ksdensity(m2);      
plot(xi,f,'r'); 
hold off


%% 

%% peaks {Retention}(M/Z,Intensity)

[P T]=mzxml2peaks(out)
%msdotplot(P,T, 'Quantile',0.95)
[MZ,Y] = msppresample(P,5000);
msheatmap(MZ,T,log(Y))
msdotplot(P,T)
ksdensity(T)
plot(P{1}(:,:))
plot(P{1}(:,1),P{1}(:,2))
plot(P{2}(:,1),P{2}(:,2))
ksdensity(P{1}(:,1))
ksdensity(P{500}(:,1))
stem(P{500}(:,1),P{500}(:,2),'marker','none')

%% Retension time sampling m/z with threshold

RT=2798
thr=771
ksdensity(P{RT}(P{RT}(:,1)>thr,1))
%plot(P{RT}(P{RT}(:,1)>thr,1))
%stem(P{RT}(P{RT}(:,1)>thr,1),P{RT}(P{RT}(:,1)>thr,2),'marker','none')
