%n2c=csvread('n2c.csv');
n2c_t=n2c(1:400,1:400);
a2ap = figure; 
%imshow(n2c_t);
imagesc(n2c_t);
c=colormap(hot);
c=flipud(c);
colormap(c);
colorbar;
xlabel('Newbler Scaffold');
ylabel('Celera Scaffolds');
title('Match-length as density plot');
%legend('De-novo Real','De-novo 800','De-novo 1600','Reference-based Real','Reference-based 800','Reference-based 1600','Location','best')
filename = 'a2ap.bmp';
print(a2ap, '-dbmp', filename);

