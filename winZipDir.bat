::winZipDir.bat f:\promec\TIMSTOF\LARS\2025\250319_Alessandro
@echo off
::zip timsTOF folder as https://console.tesorai.com/files/ expects 
::example tar -a -c -f f:\promec\TIMSTOF\LARS\2025\250319_Alessandro\250319_Alessandro_Cancer_DDA_Slot1-38_1_9855.d.zip f:\promec\TIMSTOF\LARS\2025\250319_Alessandro\250319_Alessandro_Cancer_DDA_Slot1-38_1_9855.d
set dataDir=%1
SET workDir=%cd%
if exist "%dataDir%" (
for /d %%i in ("%dataDir%\*.d") do (
  echo Processing %%i  
  if exist "%%i" (
	 start "%%i.zip" tar -a -c -f "%%i.zip" "%%i" 
  ) else (
     echo %%i NOT found
  )
 echo %%i.zip Done
 )
)  else (
  echo "%dataDir%" NOT found
)
cd %workDir%

