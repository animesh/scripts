pip=load('pip.txt')
smoothhist2d([pip(:,1),pip(:,2)],150,[150,150])
colorbar
xlabel('Percent Identity')
ylabel('Length of Match')
title('E.coli repeat analysis')