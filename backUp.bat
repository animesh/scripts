@echo off
REM https://datacornering.com/run-batch-file-minimized/  /c start /min "backup" C:\Users\QE-User\backUp.bat   ^& exit https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy https://techrando.com/2019/06/22/how-to-execute-a-task-hourly-in-task-scheduler/#:~:text=To%20set%20the%20script%20to,indefinite%20under%20the%20duration%20option.
robocopy Z:\ L:\ *.txt /xd .gd /xd .tmp.driveupload /xd .driveupload /S /E /DCOPY:DA /COPY:DAT /Z /MT:6 /R:3 /W:1 /log:F:\GD\OneDrive\logCrusher.txt