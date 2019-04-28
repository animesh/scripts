ECHO OFF
ECHO. > blank.txt
ECHO. >> blank.txt
FOR %%i IN (*.dta) DO COPY /A %%i+blank.txt %%i.tmp
COPY /A *.dta.tmp merge.txt
DEL blank.txt
DEL *.dta.tmp
ECHO All done, output file is merge.txt