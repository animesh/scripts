%% check and connect to neurosky device

instrhwinfo('Bluetooth','MindWave Mobile')
ns = Bluetooth('MindWave Mobile', 1);
fopen(ns)

%% read and plot

t=100
initLine = plot(nan);
ms=zeros(t,size(fread(ns),1))
for i = 1:t
  disp([num2str(i),'th iteration of ',num2str(t)]);
  m=(fread(ns))
  ms(i,:)=m(:);
  %set(initLine,'YData',m); 
  periodogram(fread(ns),[],'onesided',512)
drawnow               
end
dlmwrite('eegsig.txt', ms, 'delimiter', '\t', 'precision', 4)
     

%% real time play ground

scanstr(ns)

readasync(ns)

plot(hist(fread(ns)))

[n x]=(hist(fread(ns)))

hist(fread(ns)>0 & fread(ns)<10)

plot(fft(fread(ns)),'r.')

periodogram(fread(ns))


%% close connection

fclose(ns);


%% analyse signal file

ms=load('C:\Users\animeshs\OneDrive\eegsig.txt');

for i = 1:size(ms,1)
    periodogram(ms(i,:))
    drawnow
end


%% signal linearized
msl=reshape(ms',1,[]);
periodogram(msl);
cca_granger_regress(msl,1)


%% fft

msl=reshape(ms',1,[]);
plot(msl)

mslfft=fft(msl);
amslfft=abs(mslfft);
pmslfft=angle(mslfft);
plot(amslfft(1:length(msl)/2)/length(msl)/2)

i=length(mslfft)/2-1;
while i>0
[v,i]=max(amslfft(2:i));
freq=(i*size(ms,2))/(length(mslfft)/2)
end


%% power

msl=reshape(ms',1,[]);
freq = 4000;
win_PSD = 5*freq;
noverlap_PSD = [];
nFFT = 2^10;
[PSD_RSM, f] = pwelch(msl, win_PSD, noverlap_PSD, nFFT, freq)



    
%% source 
http://www.mathworks.se/help/instrument/reading-and-writing-data-over-the-bluetooth-interface.html
http://stackoverflow.com/questions/3115833/real-time-plot-in-matlab
http://www.nbtwiki.net/doku.php?id=tutorial:power_spectra_wavelet_analysis_and_coherence#.UPW_kEEcLt1
http://www.open-electronics.org/guest_projects/a-pc-and-an-arduino-heres-your-diy-oscilloscope/


