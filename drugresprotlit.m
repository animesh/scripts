%% get pubmed record for key words

%DRL=getpubmed('drug+AND+resistance+AND+proteomics','NUMBEROFRECORDS',1000)

DRL=getpubmed('drug+effect','NUMBEROFRECORDS',200)

%% do frequency count

word = regexp(lower([DRL(:).Abstract]),' ','split')';
[val,idxW, idxV] = unique(word);
num = accumarray(idxV,1);

%% exploratory 


mean(num) 
median(num)
skewness(num)
kurtosis(num)

find(abs(zscore(num))>3);

%% plot

[counts bins]=hist(num.*idxW)
plot(bins, counts)

ksdensity(num)

hist(log(num),[40])

histfit(num)
probplot('normal',num)


%% source

http://www.mathworks.com/matlabcentral/answers/39759
http://www.mathworks.se/help/bioinfo/ug/creating-get-functions.html
http://stackoverflow.com/questions/2597743/matlab-frequency-distribution
http://www.mathworks.se/help/stats/example.html

%% tika tools

http://pdfbox.apache.org/commandlineutilities/Overlay.html

java -jar C:\Users\animeshs\SkyDrive\pdfbox-app-1.7.1.jar ExtractText "V:\felles\PROTEOMICS and XRAY\Articles in prep\AAG\litsur\MCP-2006-Stewart-433-43.pdf"


