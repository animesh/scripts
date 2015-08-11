set SGDIR=C:\Users\animeshs\SkyDrive\SearchGUI-1.11.0_windows\SearchGUI-1.11.0_windows
set DB=C:/Users/animeshs/SkyDrive/MaxQuant/fasta/HUMAN_concatenated_target_decoy.fasta
set PW=C:\Users\animeshs\SkyDrive\pwiz-bin-windows-x86-vc100-release-3_0_4323
set DATADIR=X:\Qexactive
set PREFIXRAW=What-the-hek-
set PT=15
set FT=0.8
set enzyme=Trypsin
set MC=3

DIR /B %DATADIR%\%PREFIXRAW%*.raw > %DATADIR%\tempfile.txt

FOR /F "eol=  tokens=1,2 delims=." %%i in (%DATADIR%\tempfile.txt) do  ( 
	if not %%i ==   "" (
		if not exist %DATADIR%\%%i.mgf %PW%\msconvert.exe -o %DATADIR% %DATADIR%\%%i.raw --mgf
		if not exist %DATADIR%\%%i-sguiout mkdir %DATADIR%\%%i-sguiout
		java -cp %SGDIR%\SearchGUI-1.11.0.jar eu.isas.searchgui.cmd.SearchCLI  -spectrum_files %DATADIR%\%%i.mgf  -output_folder %DATADIR%\%%i-sguiout -prec_tol %PT% -frag_tol %FT% -enzyme %enzyme% -db %DB% "" -mc %MC%
	)
)


GOTO :Source 


:Source 

:: http://proteowizard.sourceforge.net/tools/msconvert.html
:: http://code.google.com/p/searchgui/wiki/SearchCLI