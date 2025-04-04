@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
:: change the following paths according to the MaxQuant Installation, directory containing experiment raw files, fasta file and representative parameter file for that version respectively
set MAXQUANTCMD="C:\Program Files\MaxQuant_v2.6.7.0\bin\MaxQuantCmd.exe"
set DATADIR="F:\promec\TIMSTOF\LARS\2025\250402_dda_Hela"
set FASTAFILE=F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta
set PARAMFILE=mqpar.xml
set TMPDIR=D:\TMPDIR
set DT=%date:~-4,4%%date:~-10,2%%date:~7,2%
set TS=%time:~-11,2%%time:~3,2%%time:~6,2%
mkdir %TMPDIR%\%PARAMFILE%_%DT%_%TS%
:: leave following empty to include ALL files
set SEARCHTEXT=TestDir
set SEARCHTEXT2=SequencesFasta
:: taskkill /f /im maxquant*
:: taskkill /f /im dotnet*
for /d %%i in (%DATADIR%\250327_HELA*DDA*.d) do  (
  dir %%i
  mkdir %TMPDIR%\%PARAMFILE%_%DT%_%TS%\%%~ni.results
  mkdir %TMPDIR%\%PARAMFILE%_%DT%_%TS%\%%~ni.results\data.d
  if exist %%i.results\%PARAMFILE% del %%i.results\%PARAMFILE%
	for /f "tokens=1,* delims=" %%A in ( '"type %PARAMFILE%"') do (
	SET string=%%A
	SET modified=!string:%SEARCHTEXT%=%TMPDIR%\%PARAMFILE%_%DT%_%TS%\%%~ni.results\data.d!
	SET modified2=!modified:%SEARCHTEXT2%=%FASTAFILE%!
  echo !modified2! >> %TMPDIR%\%PARAMFILE%_%DT%_%TS%\%%~ni.results\%PARAMFILE%
  )
  echo D| xcopy  /E /Y /Q %%i %TMPDIR%\%PARAMFILE%_%DT%_%TS%\%%~ni.results\data.d
  dir %TMPDIR%\%PARAMFILE%_%DT%_%TS%\%%~ni.results
  start "MQ.%DT%.%TS%.%%i" %MAXQUANTCMD% %TMPDIR%\%PARAMFILE%_%DT%_%TS%\%%~ni.results\%PARAMFILE%
)
:: https://stackoverflow.com/a/16079895
:: https://stackoverflow.com/a/13805466
:: https://stackoverflow.com/a/55519158
:: https://stackoverflow.com/a/30231479
