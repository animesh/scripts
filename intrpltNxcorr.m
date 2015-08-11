%% read
d=xlsread('C:\Users\animeshs\SkyDrive\Gotland 125m Landsort Deep 400m.xls')
d=xlsread('C:\Users\animeshs\SkyDrive\Density and year basin 1 and basin 2.xls')
d=xlsread('C:\Users\animeshs\SkyDrive\Animesh cross correlation.xls')


%% test

t1 = 1960:10:1990
d1 = sin(t1)
plot(t1,d1,'r.')
t2= 1970:1:2000
d2 = interp1(t1,d1,t2,'spline')
%d2 = interp1(t1,d1,t2)
plot(t1,d1,'o',t2,d2)
xcorr(d1,d2)
[v i]=max(~isnan(cc))

d2ond1viat1=interp1(uAt1,uAd1,uAt2)
plot(d2ond1viat1,uAd2,'r.')
[cc lags]=xcorr(d2ond1viat1(~isnan(d2ond1viat1)),uAd2(~isnan(d2ond1viat1)))
[v i]=max(~isnan(cc))
i((lags(i)))


%% extract time and values

d1=d(~isnan(d(:,2)),2)
i1=d(~isnan(d(:,2)),1)

[uAt, ~, ui] = unique(i1)
n = hist( ui, 1:max(ui) );
sel = n == 1
hist(n)
uAt1 = uAt(sel, :);
uAd1 = d1(sel, :);

d2=d(~isnan(d(:,6)),6)
i2=d(~isnan(d(:,6)),5)

[uAt, ~, ui] = unique(i2)
n = hist( ui, 1:max(ui) );
sel = n == 1
hist(n)
uAt2 = uAt(sel, :);
uAd2 = d2(sel, :);


plot(i1,d1)
hold
plot(i2,d2,'r-')
plot(uAt1,uAd1,'g-')
plot(uAt2,uAd2,'k-')
hold off

uAd1i = interp1(uAt1,uAd1,uAt2)
uAd2i = interp1(uAt2,uAd2,uAt1)

plot(i1,d1,'b-')
hold
plot(i2,d2,'r-')
plot(uAt2,uAd1i,'g-')
plot(uAt1,uAd2i,'y-')
hold off

savevar=[uAt2,uAd1i];
save('interpolatedd1.txt', 'savevar', '-ASCII')

savevar=[uAt1,uAd2i];
save('interpolatedd2.txt', 'savevar', '-ASCII')

[cc lags]=xcorr(uAd1i(~isnan(uAd1i)),uAd2(~isnan(uAd1i)))
[cc lags]=xcorr(uAd2i(~isnan(uAd2i)),uAd1(~isnan(uAd2i)),'coeff')
plot(lags,cc,'r.');

[v i]=max(~isnan(cc));
i1((lags(i)))



%% overlay
plot(d(:,6),d(:,7))
hold
plot(d(:,1),d(:,2),'r-')
hold off

%% interpolate and cross correlate

t1min=min([d(:,1)])
t2min=min([d(:,6)])
t3min=min([d(:,3)])
t1max=max([d(:,1)])
t2max=max([d(:,6)])
t3max=max([d(:,3)])

tmin=max([t1min,t2min,t3min])
tmax=min([t1max,t2max,t3max])

d1=d(d(:,1)>=tmin & d(:,1)<= tmax & ~isnan(d(:,2)),2)
i1=d(d(:,1)>=tmin & d(:,1)<= tmax & ~isnan(d(:,2)),1)

d3=d(d(:,3)>=tmin & d(:,3)<= tmax & ~isnan(d(:,2)) & ~isnan(d(:,3)),2)
i3=d(d(:,3)>=tmin & d(:,3)<= tmax & ~isnan(d(:,2)) & ~isnan(d(:,3)),3)

d2=d(d(:,6)>=tmin & d(:,6)<= tmax & ~isnan(d(:,7)),7)
i2=d(d(:,6)>=tmin & d(:,6)<= tmax & ~isnan(d(:,7)),6)

[uAt2, ~, ui] = unique(i2)
n = hist( ui, 1:max(ui) );
sel = n == 1
hist(n)
uAt2 = uAt2(sel, :);
uAd2 = d2(sel, :);

d2i = interp1(uAt2,uAd2,i1,'spline')
plot(d2i,d1,'r.')

plot(i1,d2i)
hold
plot(i1,d1,'r-')
hold off


[cc lags]=xcorr(d2i,d1,'coeff')
%h=figure;
plot(lags,cc,'r.');
%saveas(h,'test','jpg');

[v i]=max(~isnan(cc))
i1((lag(i)))

savevar=[uAt2,uAd2];
save('interpolatedd2.txt', 'savevar', '-ASCII')



%% compare

plot(i3,d3)
hold
plot(uAt3,uAd3,'r-')
plot(i2,d2,'k-')
hold off


%% source
% http://www.mathworks.se/help/matlab/ref/interp1.html
% http://stackoverflow.com/questions/13883489/remove-all-the-rows-with-same-values-in-matlab
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/248731
% http://www.mathworks.com/matlabcentral/answers/48639
