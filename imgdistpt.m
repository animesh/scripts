[A,map,alpha] = imread('C:\Users\animeshs\Desktop\IMG_20130620_112511.jpg');

image(A)

p=ginput(2)
sqrt(sum((p(:,1) - p(:,2)).^2))


%% source
http://www.mathworks.se/help/matlab/ref/imread.html
http://stackoverflow.com/questions/10695747/distance-between-two-points-in-a-image-in-matalb