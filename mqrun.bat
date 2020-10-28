::@echo off
:: change the following paths according to the MaxQuant Installation, directory containing experiment raw files, fasta file and representative parameter file for that version respectively
set MAXQUANTCMD=C:\Users\animeshs\MaxQuant_1.6.17.0.zip\MaxQuant\bin\MaxQuantCmd.exe
set DATADIR=F:\SINTEF
set FASTAFILE=F:\SINTEF\AP-004_translations.fa
set PARAMFILE=mqpar.xml
:: leave following empty to include ALL files
set PREFIXRAW=
DIR /B %DATADIR%\%PREFIXRAW%*.raw > %DATADIR%\tempfile.txt
set SEARCHTEXT=TestFile
set SEARCHTEXT2=SequencesFasta

FOR /F "eol=  tokens=1,2 delims=." %%i in (%DATADIR%\tempfile.txt) do  (
	if not %%i ==   "" (
		call :Change %%i
		if exist proc rmdir /S /Q proc
		if exist %DATADIR%\combined rmdir /S /Q %DATADIR%\combined
		if exist %DATADIR%\%%i rmdir /S /Q %DATADIR%\%%i
		%MAXQUANTCMD% %DATADIR%\%%i.xml
		if exist %DATADIR%\%%iREP rmdir /S /Q %DATADIR%\%%iREP
		echo D| xcopy  /E /Y /Q %DATADIR%\combined\txt %DATADIR%\%%iREP
		:: if exist %DATADIR%\%%iREP copy %DATADIR%\combined\andromeda\*.apl %DATADIR%\%%iREP
		if exist %DATADIR%\%%i rmdir /S /Q %DATADIR%\%%i
		if exist proc rmdir /S /Q proc
		if exist %DATADIR%\combined rmdir /S /Q %DATADIR%\combined
	)
)

GOTO :Source

:Change

	setlocal enabledelayedexpansion

	set FileN=%~1
	set INTEXTFILE=%PARAMFILE%
	set OUTTEXTFILE=%DATADIR%\%FileN%.xml
	set REPLACETEXT=%DATADIR%\%FileN%
	set REPLACETEXT2=%FASTAFILE%
	set OUTPUTLINE=

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

:: https://irfanview-forum.de/showthread.php?t=3263
:: http://stackoverflow.com/questions/5273937/how-to-replace-substrings-in-windows-batch-file
:: http://www.pcreview.co.uk/forums/delims-t1466398.html
:: http://www.robvanderwoude.com/for.php
:: http://stackoverflow.com/questions/3713601/subroutines-in-batch-files
:: https://superuser.com/a/682946
:: update at sharma.animesh@gmail.com :)
