::@echo off
:: change the following paths according to the MaxQuant Installation, directory containing experiment raw files, fasta file and representative parameter file for that version respectively
set MAXQUANTCMD="C:\Program Files\MaxQuant_v2.6.5.0\bin\MaxQuantCmd.exe"
set DATADIR=F:\promec\TIMSTOF\LARS\2024\241219_Hela_DDA_DIA\dda
set FASTAFILE=F:\promec\FastaDB\UP000005640_9606_UP000000625_83333_unique_gene.fasta
set PARAMFILE=mqpar.xml
:: leave following empty to include ALL files
dir /s /b /o:n /ad  %DATADIR%\241217_2ngHelaQC_DDAc_Slot1-29_1_9281*.d > %DATADIR%\tempfile.txt
set SEARCHTEXT=TestDir
set SEARCHTEXT2=SequencesFasta

for /f "tokens=*" %%i in (%DATADIR%\tempfile.txt) do  (
		if not %%i ==   "" (
	  call :Change %%i
		:: if exist proc rmdir /S /Q proc
		:: if exist %DATADIR%\combined rmdir /S /Q %DATADIR%\combined
		:: if exist %DATADIR%\%%i rmdir /S /Q %DATADIR%\%%i
		%MAXQUANTCMD% %%i.xml
		:: if exist %DATADIR%\%%iREP rmdir /S /Q %DATADIR%\%%iREP
		:: echo D| xcopy  /E /Y /Q %DATADIR%\combined\txt %DATADIR%\%%iREP
		:: if exist %DATADIR%\%%iREP copy %DATADIR%\combined\andromeda\*.apl %DATADIR%\%%iREP
		:: if exist %DATADIR%\%%i rmdir /S /Q %DATADIR%\%%i
		:: if exist proc rmdir /S /Q proc
		:: if exist %DATADIR%\combined rmdir /S /Q %DATADIR%\combined
 	)
)

GOTO :Source

:Change

	setlocal enabledelayedexpansion

	set FileN=%~1
	set INTEXTFILE=%PARAMFILE%
	set OUTTEXTFILE=%FileN%.xml
	set REPLACETEXT=%FileN%
	set REPLACETEXT2=%FASTAFILE%

	if exist %OUTTEXTFILE% del %OUTTEXTFILE%
	for /f "tokens=1,* delims=" %%A in ( '"type %INTEXTFILE%"') do (
	SET string=%%A
	SET modified=!string:%SEARCHTEXT%=%REPLACETEXT%!
	SET modified2=!modified:%SEARCHTEXT2%=%REPLACETEXT2%!
	if not x%string:%SEARCHTEXT2%=%==x%string% (echo !modified2! >> %OUTTEXTFILE%) else (
	if not x%string:%SEARCHTEXT%=%==x%string% (echo !modified! >> %OUTTEXTFILE%)
  else (echo %string% >> %OUTTEXTFILE%)
		)
)

:Source
:: https://stackoverflow.com/a/16079895
:: https://irfanview-forum.de/showthread.php?t=3263
:: http://stackoverflow.com/questions/5273937/how-to-replace-substrings-in-windows-batch-file
:: http://www.pcreview.co.uk/forums/delims-t1466398.html
:: http://www.robvanderwoude.com/for.php
:: http://stackoverflow.com/questions/3713601/subroutines-in-batch-files
:: https://superuser.com/a/682946
:: update at sharma.animesh@gmail.com :)
