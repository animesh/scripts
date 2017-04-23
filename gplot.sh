cd 'D:\animesh\booksNpapers\lang\gnuplot';\
splot 'feat.txt' index 0 title "EWS";\
replot 'feat.txt' index 1 title "BL";\
replot 'feat.txt' index 2 title "NB";\
replot 'feat.txt' index 3 title "RMS";\
set term png small;\
set out "featall.png";\
replot;\
set out;\
set terminal windows;\
replot;\
save 'D:\animesh\booksNpapers\lang\gnuplot\plot.plt';


#EWS	BL	NB	RMS
#23	8	12	20


splot 'grid.txt' index 0 title "";\
replot 'grid.txt' index 1 title "BL";\
replot 'grid.txt' index 2 title "NB";\
replot 'grid.txt' index 3 title "RMS";\
