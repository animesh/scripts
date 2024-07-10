@ECHO OFF
echo starting simulator ...
set CONDAPATH=C:\ProgramData\Bruker\Miniconda3
set ENVNAME=timsEngine
if %ENVNAME%==base (set ENVPATH=%CONDAPATH%) else (set ENVPATH=%CONDAPATH%\envs\%ENVNAME%)
call %CONDAPATH%\Scripts\activate.bat %ENVPATH%
:: simulator -q -l 0 -d 2 -r 0 -i "D:\Data\LARS\240626_Mira\240626_Mira_18_Slot1-18_1_7907.d" -s dda --token 3997955b-252b-4e75-ab16-d97a25097b4e
for /d %%j in ("D:\Data\LARS\240626_Mira\*.d") do simulator -q -l 10 -d 20 -r 0 -i "%%j" -s dda --token 3997955b-252b-4e75-ab16-d97a25097b4e
:: via cmd for /d %j in ("D:\Data\LARS\230508_IRD\*glu*.d") do (simulator -i %j --pid 5450 --wid 21 -s dda -q)
Pause