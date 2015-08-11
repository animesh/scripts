set MAXQUANTDIR=F:\promec\MaxQuant1412
set THREADS=4
set DATADIR=F:\promec\Elite\Celine\DMSO\test
set PREFIXRAW=
set PARAMFILE=mqpar.xml
set SEARCHTEXT=TestFile

DIR /B %DATADIR%\%PREFIXRAW%*.raw > %DATADIR%\tempfile.txt

FOR /F "eol=  tokens=1,2 delims=." %%i in (%DATADIR%\tempfile.txt) do  ( 
	if not %%i ==   "" (
		call :Change %%i
		if exist proc rmdir /S /Q proc
		if exist %DATADIR%\combined rmdir /S /Q %DATADIR%\combined
		if exist %DATADIR%\%%i rmdir /S /Q %DATADIR%\%%i
		%MAXQUANTDIR%\bin\MaxQuantCmd.exe -mqpar=%DATADIR%\%%i.xml -ncores=%THREADS%
		if exist %DATADIR%\%%iREP rmdir /S /Q %DATADIR%\%%iREP
		echo D| xcopy  /E /Y /Q %DATADIR%\combined\txt %DATADIR%\%%iREP
		if exist %DATADIR%\%%iREP copy %DATADIR%\combined\andromeda\*.apl %DATADIR%\%%iREP
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
	set REPLACETEXT=%FileN%
	set OUTPUTLINE=

	if exist %OUTTEXTFILE% del %OUTTEXTFILE%
	for /f "tokens=1,* delims=¶" %%A in ( '"type %INTEXTFILE%"') do (
	SET string=%%A
	SET modified=!string:%SEARCHTEXT%=%REPLACETEXT%!

	echo !modified! >> %OUTTEXTFILE%
	)

:Source 

:: https://irfanview-forum.de/showthread.php?t=3263 
:: http://stackoverflow.com/questions/5273937/how-to-replace-substrings-in-windows-batch-file
:: http://www.pcreview.co.uk/forums/delims-t1466398.html
:: http://www.robvanderwoude.com/for.php
:: http://stackoverflow.com/questions/3713601/subroutines-in-batch-files
:: update at sharma.animesh@gmail.com :)
