#set PATH=%PATH%;C:\ProgramData\Bruker\Miniconda3\envs\timsEngine\Library\bin;
#set PATH=%PATH%;C:\ProgramData\Bruker\Miniconda3\envs\timsEngine;
#set PATH=%PATH%;C:\ProgramData\Bruker\Miniconda3\envs\timsEngine\Scripts;
#for /d %j in ("D:\Data\LARS\230419_evosep\2320419_plasma_pCA_?_S1*.d") do (simulator -i %j --pid 5449 --wid 19 -s dda -q)#--pid 5449 --wid 18 -s dia
