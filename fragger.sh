#https://github.com/Nesvilab/philosopher/wiki/Simple-Data-Analysis
#FragPipe version 13.0
#MSFragger version 3.0
#Philosopher version 3.2.9 (build 1593192429)
#Pseudomonas project
ln -s /mnt/z/PA
cd PA
philosopher workspace --clean --nocheck
philosopher workspace --init --nocheck
/home/animeshs/GD/philosopher_v3.2.9_linux/philosopher workspace --init
/home/animeshs/GD/philosopher_v3.2.9_linux/philosopher database --reviewed --contam --id  UP000002438
java -jar /home/animeshs/GD/MSFragger-3.0/MSFragger-3.0.jar fragger.open.params 140605_Pseudomonas_O1_K0K6.raw
for in in *.raw ; do echo $i ; java -jar /home/animeshs/GD/MSFragger-3.0/MSFragger-3.0.jar fragger.open.params $i ; done
java -jar -Dfile.encoding=UTF-8 -Xmx64G MSFragger-3.0.jar
java -cp fragpipe/lib/fragpipe-13.0.jar com.github.chhh.utils.FileMove PA/140605_Pseudomonas_O1_K0K6_T2.pepXML GD/Raw/140605_Pseudomonas_O1_K0K6_T2.pepXML
java -Dbatmass.io.libs.thermo.dir="GD/MSFragger-3.0/ext/thermo" -Xmx64G -cp "GD/fragpipe/tools/original-crystalc-1.2.1.jar;GD/fragpipe/tools/batmass-io-1.17.4.jar;GD/fragpipe/tools/grppr-0.3.23.jar" crystalc.Run GD/Raw/crystalc-0-140605_Pseudomonas_O1_K0K6_T2.pepXML.params GD/Raw/140605_Pseudomonas_O1_K0K6_T2.pepXML
PeptideProphet [Work dir: GD/Raw]
GD/philosopher peptideprophet --nonparam --expectscore --decoyprobs --masswidth 1000.0 --clevel -2 --decoy rev_ --database Z:/PA/2020-07-19-decoys-reviewed-contam-UP000002438.fas --combine 140605_Pseudomonas_O1_K0K6_T2_c.pepXML
ProteinProphet [Work dir: GD/Raw]
GD/philosopher proteinprophet --maxppmdiff 2000000 --output combined GD/Raw/interact.pep.xml
PhilosopherDbAnnotate [Work dir: GD/Raw]
GD/philosopher database --annotate Z:/PA/2020-07-19-decoys-reviewed-contam-UP000002438.fas --prefix rev_
PhilosopherFilter [Work dir: GD/Raw]
GD/philosopher filter --sequential --razor --mapmods --prot 0.01 --tag rev_ --pepxml GD/Raw --protxml GD/Raw/combined.prot.xml
PhilosopherReport [Work dir: GD/Raw]
GD/philosopher report --mzid
IonQuant [Work dir: GD/Raw]
GD/fragpipe/jre/bin/java -Xmx64G -Dlibs.bruker.dir="GD/MSFragger-3.0/ext/bruker" -Dlibs.thermo.dir="GD/MSFragger-3.0/ext/thermo" -cp "GD/fragpipe/tools/ionquant-1.3.6.jar;GD/fragpipe/tools/batmass-io-1.17.4.jar" ionquant.IonQuant --threads 23 --ionmobility 0 --mbr 0 --proteinquant 1 --requantify 0 --mztol 10 --imtol 0.05 --rttol 0.4 --mbrmincorr 0.5 --mbrrttol 1 --mbrimtol 0.05 --mbrtoprun 3 --ionfdr 0.01 --proteinfdr 0.01 --peptidefdr 0.01 --normalization 1 --minisotopes 2 --tp 3 --minfreq 0.5 --minions 2 --psm GD/Raw/psm.tsv Z:/PA/140605_Pseudomonas_O1_K0K6_T2.raw 140605_Pseudomonas_O1_K0K6_T2.pepXML
WorkspaceClean [Work dir: GD/Raw]
GD/philosopher workspace --clean --nocheck
PTMShepherd [Work dir: GD/Raw]
GD/fragpipe/jre/bin/java -Dbatmass.io.libs.thermo.dir="GD/MSFragger-3.0/ext/thermo" -cp "GD/fragpipe/tools/ptmshepherd-0.3.4.jar;GD/fragpipe/tools/batmass-io-1.17.4.jar;GD/fragpipe/tools/commons-math3-3.6.1.jar" edu.umich.andykong.ptmshepherd.PTMShepherd "GD/Raw/shepherd.config"
