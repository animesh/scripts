set FRAGPIPE=F:\GD\fragpipe
set LIB=%FRAGPIPE%\lib
set TOOLS=%FRAGPIPE%\tools
set FP=%LIB%\fragpipe-14.0.jar
set MSFRAGGER=%TOOLS%\MSFragger-3.1\MSFragger-3.1.jar
set THERMO=%TOOLS%\MSFragger-3.1\ext\thermo
set CC=%TOOLS%\original-crystalc-1.3.2.jar
set BM=%TOOLS%\batmass-io-1.19.5.jar
set GRPPR=%TOOLS%\grppr-0.3.23.jar
set PHILOSOPHER=C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe
set FASTA=%HOME%/FastaDB/uniprot-Phaeodactylum-tricornutum-iso-Feb20.fasta
set DATA=F:\promec\USERS\MarianneNymark\20200108_15-samples\HF\2021run
cd %DATA%

GOTO :Source

%PHILOSOPHER% workspace --clean --nocheck
%PHILOSOPHER% workspace --init .
%PHILOSOPHER% database --reviewed --contam --id  UP000000759

java -jar -Dfile.encoding=UTF-8 -Xmx76G %MSFRAGGER% %DATA%\fragger.params %DATA%\201111_Shengdong_IP_sample3.raw
mkdir  Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\201111_Shengdong_IP_sample3\
java -cp %FP% com.github.chhh.utils.FileMove %DATA%\201111_Shengdong_IP_sample3.pepXML %DATA%\201111_Shengdong_IP_sample3\201111_Shengdong_IP_sample3.pepXML
java -cp %FP% com.github.chhh.utils.FileMove --no-err %DATA%\201111_Shengdong_IP_sample3.tsv %DATA%\201111_Shengdong_IP_sample3\201111_Shengdong_IP_sample3.tsv
java -Dbatmass.io.libs.thermo.dir=%THERMO% -Xmx76G -cp "%CC%;%BM%;%GRPPR%" crystalc.Run %DATA%\201111_Shengdong_IP_sample3\crystalc-0-201111_Shengdong_IP_sample3.pepXML.params %DATA%\201111_Shengdong_IP_sample3\201111_Shengdong_IP_sample3.pepXML
%PHILOSOPHER% peptideprophet --nonparam --expectscore --decoyprobs --masswidth 1000.0 --clevel -2 --decoy rev_ --database %FASTA% --combine 201111_Shengdong_IP_sample3_c.pepXML
java -cp %LIB%"/* com.dmtavt.fragpipe.util.RewritePepxml Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\201111_Shengdong_IP_sample3\interact.pep.xml Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\201111_Shengdong_IP_sample3.raw
ProteinProphet [Work dir: Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe proteinprophet --maxppmdiff 2000000 --output combined Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\201111_Shengdong_IP_sample3\interact.pep.xml
PhilosopherDbAnnotate [Work dir: Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\201111_Shengdong_IP_sample3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\2020-11-26-decoys-reviewed-contam-UP000005640.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\2020-11-26-decoys-reviewed-contam-UP000005640.fas --prefix rev_
PhilosopherFilter [Work dir: Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\201111_Shengdong_IP_sample3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\201111_Shengdong_IP_sample3 --protxml Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\combined.prot.xml
PhilosopherReport [Work dir: Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\201111_Shengdong_IP_sample3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
WorkspaceClean [Work dir: Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\201111_Shengdong_IP_sample3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
PTMShepherd [Work dir: Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP]
java -Dbatmass.io.libs.thermo.dir="C:\Users\animeshs\GD\fragpipe\tools\MSFragger-3.1\ext\thermo" -cp "C:\Users\animeshs\GD\fragpipe\tools\ptmshepherd-0.4.0.jar;C:\Users\animeshs\GD\fragpipe\tools\batmass-io-1.19.5.jar;C:\Users\animeshs\GD\fragpipe\tools\commons-math3-3.6.1.jar" edu.umich.andykong.ptmshepherd.PTMShepherd "Z:\promec\USERS\Shengdong\201111_IP-and-inputs_12samples\QE\IP\shepherd.config"

:Source

:: Please cite:
:: (Regular searches) MSFragger: ultrafast and comprehensive peptide identification in mass spectrometry–based proteomics. Nat Methods 14:513 (2017)
:: (Open search) Identification of modified peptides using localization-aware open search. Nat Commun. 11:4065 (2020)
:: (Open search) Crystal-C: A Computational Tool for Refinement of Open Search Results. J. Proteome Res. 19.6:2511 (2020)
:: (Open search) PTM-Shepherd: analysis and summarization of post-translational and chemical modifications from open search results. bioRxiv. DOI: 10.1101/2020.07.08.192583 (2020)
:: (Glyco/labile search) Fast and comprehensive N- and O-glycoproteomics analysis with MSFragger-Glyco. Nat Methods DOI: 10.1101/2020.05.18.10266 (2020)
:: (timsTOF PASEF) Fast quantitative analysis of timsTOF PASEF data with MSFragger and IonQuant. Mol Cell Proteomics 19: 1575 (2020)
:: (PeptideProphet/ProteinProphet/PTMProphet/Filtering) Philosopher: a versatile toolkit for shotgun proteomics data analysis. Nat Methods 17:869 (2020)
:: (TMT-Integrator) Quantitative proteomic landscape of metaplastic breast carcinoma pathological subtypes and their relationship to triple-negative tumors. Nat Commun. 11:1723 (2020)
:: (DIA-Umpire) DIA-Umpire: comprehensive computational framework for data-independent acquisition proteomics. Nat Methods 12:258 (2015)
