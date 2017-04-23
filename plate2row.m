rawdata=xlsread('96wellPLateData.xlsx');
step=10;
fresult = fopen('combo.txt','w');
for i=1:size(rawdata,1)
    if rem(i,step)==1
       ceil(i/step)
       fprintf(fresult,'Plate-%d\n',ceil(i/step));
    elseif rem(i,step)<11
       reshape(rawdata(i,:),size(rawdata,2),1)
       if ~isnan(rawdata(i,:))
           fprintf(fresult,'%f\n',reshape(rawdata(i,:),size(rawdata,2),1));
       end
    end
end
fclose(fresult)