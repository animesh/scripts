@echo off
REM https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy https://techrando.com/2019/06/22/how-to-execute-a-task-hourly-in-task-scheduler/#:~:text=To%20set%20the%20script%20to,indefinite%20under%20the%20duration%20option.
robocopy \\promec01.win.ntnu.no\promec\promec\ z:\promec\ /e /mt /z  /log:L:\logCrusher.txt