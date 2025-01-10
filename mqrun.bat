@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
:: change the following paths according to the MaxQuant Installation, directory containing experiment raw files, fasta file and representative parameter file for that version respectively
set MAXQUANTCMD="C:\Program Files\MaxQuant_v2.6.5.0\bin\MaxQuantCmd.exe"
set DATADIR=F:\promec\TIMSTOF\LARS\2025\250107_Hela_Coli\DDA
set FASTAFILE=F:\promec\FastaDB\UP000005640_9606_UP000000625_83333_unique_gene.fasta
set PARAMFILE=mqpar.xml
:: leave following empty to include ALL files
set SEARCHTEXT=TestDir
set SEARCHTEXT2=SequencesFasta
taskkill /f /im maxquant*
taskkill /f /im dotnet*
for /d %%i in (%DATADIR%\*.d) do  (
  if exist %%i.xml del %%i.xml
	for /f "tokens=1,* delims=" %%A in ( '"type %PARAMFILE%"') do (
	SET string=%%A
	SET modified=!string:%SEARCHTEXT%=%%i!
	SET modified2=!modified:%SEARCHTEXT2%=%FASTAFILE%!
  echo !modified2! >> %%i.xml
  )
  dir %%i.xml
  %MAXQUANTCMD% %%i.xml
  echo D| xcopy  /E /Y /Q %DATADIR%\combined\txt %%i.xml.result
)
:: https://stackoverflow.com/a/16079895
:: https://stackoverflow.com/a/13805466
