@echo off
robocopy D:\Data \\promec01.medisin.ntnu.no\promec\promec\TIMSTOF\Raw /xd BrukerDBBackup /xd .driveupload /xd BrukerDBData /xd .tmp.driveupload /xd .gd /S /MIR /DCOPY:DA /COPY:DAT /J /Z /MT:8 /R:0 /W:0  /log:\\promec01.medisin.ntnu.no\promec\promec\logs\logTTP.txt
::  HF 
::  Action Program/script 
::  cmd
::  /c start /min "backup" C:\Users\HFuser\backUp.bat  ^& exit
::  robocopy C:\Xcalibur\data \\promec01.medisin.ntnu.no\promec\promec\HF\Raw *.raw /xd .driveupload /xd .gd /xd .tmp.driveupload /S /MIR /DCOPY:DA /COPY:DAT /J /Z /MT:8 /R:0 /W:0  /log:\\promec01.medisin.ntnu.no\promec\promec\logs\logHF.txt
::  QE 
::  robocopy C:\Xcalibur\data \\promec01.medisin.ntnu.no\promec\promec\Qexactive\Raw  *.raw /xd .gd /xd .driveupload  /xd .tmp.driveupload  /S /MIR /DCOPY:DA /COPY:DAT /J /Z /MT:8 /R:0 /W:0 /log:\\promec01.medisin.ntnu.no\promec\promec\logs\logQE.txt
