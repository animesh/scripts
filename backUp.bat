@echo off
robocopy D:\Data \\promec01.medisin.ntnu.no\promec\promec\TIMSTOF\Raw /xd BrukerDBBackup /xd .driveupload /xd BrukerDBData /xd .tmp.driveupload /xd .gd /S /MIR /DCOPY:DA /COPY:DAT /J /Z /MT:8 /R:0 /W:0  /log:\\promec01.medisin.ntnu.no\promec\promec\logs\logTTP.txt
::  