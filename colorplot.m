function colorplot(filename)
% colorplot(filename) plot and save the data as a 2-d color plot. 
%
% INPUT:
%   filename - must contain 2d numeric data, 1 column per lane, 1 row
%   per tile.
%
% OUTPUT:
%   - the plot is created with a colorbar, title=filename, and default
%  axes
%
%   - filename.jpg: the plot in jpg format
%   - filename.pdf: the plot in pdf format
%   - filename.ps: the plot in postscript format

if(nargin ~= 1)
   disp('1 input arguments is required');
   return
end

data = load ('-ascii', filename);
figure;
imagesc(data);
colorbar;
title(filename);

print('-djpeg100', strcat(filename, '.jpg'));
print('-dpsc2','-r1200', strcat(filename, '.ps'));
system(['ps2pdf ' filename '.ps ' filename '.pdf']);
