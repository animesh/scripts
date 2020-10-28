C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
java -jar -Dfile.encoding=UTF-8 -Xmx57G C:\Users\animeshs\GD\fragpipe\tools\MSFragger-3.1\MSFragger-3.1.jar F:\SINTEF\fragger.params F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8.raw F:\SINTEF\200925_SINTEF_sample-T2-M4_positionB5.raw F:\SINTEF\200925_SINTEF_sample-T2-M5_positionA6.raw F:\SINTEF\200925_SINTEF_sample-T2-M6_positionB6.raw F:\SINTEF\200925_SINTEF_sample-T2-M7_positionB3.raw F:\SINTEF\200925_SINTEF_sample-T2-M8_positionB8.raw F:\SINTEF\200925_SINTEF_sample-T5-M3_positionB1.raw F:\SINTEF\200925_SINTEF_sample-T5-M4_positionC1.raw F:\SINTEF\200925_SINTEF_sample-T5-M5_positionA3.raw F:\SINTEF\200925_SINTEF_sample-T5-M6_positionA2.raw F:\SINTEF\200925_SINTEF_sample-T5-M7_positionA4.raw F:\SINTEF\200925_SINTEF_sample-T5-M8_positionB7.raw F:\SINTEF\200925_SINTEF_sample-T6-M7_positionB2.raw F:\SINTEF\200925_SINTEF_sample-T6-M8_positionA5.raw F:\SINTEF\200925_SINTEF_sample-T7-M3_positionA1.raw F:\SINTEF\200925_SINTEF_sample-T7-M4_positionC2.raw F:\SINTEF\200925_SINTEF_sample-T7-M5_positionB4.raw F:\SINTEF\200925_SINTEF_sample-T7-M6_positionA7.raw
java -cp C:\Users\animeshs\GD\fragpipe\lib\fragpipe-14.0.jar com.github.chhh.utils.FileMove F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8.pepXML
java -cp C:\Users\animeshs\GD\fragpipe\lib\fragpipe-14.0.jar com.github.chhh.utils.FileMove --no-err F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8.tsv F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8\200925_SINTEF_sample-T2-M3_positionA8.tsv
java -Dbatmass.io.libs.thermo.dir="C:\Users\animeshs\GD\fragpipe\tools\MSFragger-3.1\ext\thermo" -Xmx57G -cp "C:\Users\animeshs\GD\fragpipe\tools\original-crystalc-1.3.2.jar;C:\Users\animeshs\GD\fragpipe\tools\batmass-io-1.19.5.jar;C:\Users\animeshs\GD\fragpipe\tools\grppr-0.3.23.jar" crystalc.Run F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8\crystalc-1-200925_SINTEF_sample-T2-M3_positionA8.pepXML.params F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8\200925_SINTEF_sample-T2-M3_positionA8.pepXML
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe peptideprophet --nonparam --expectscore --decoyprobs --masswidth 1000.0 --clevel -2 --decoy rev_ --database F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --combine 200925_SINTEF_sample-T2-M3_positionA8_c.pepXML
java -cp C:\Users\animeshs\GD\fragpipe\lib/* com.dmtavt.fragpipe.util.RewritePepxml F:\SINTEF\200925_SINTEF_sample-T5-M3_positionB1\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T5-M3_positionB1.raw
java -cp C:\Users\animeshs\GD\fragpipe\lib/* com.dmtavt.fragpipe.util.RewritePepxml F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8.raw
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe proteinprophet --maxppmdiff 2000000 --output combined F:\SINTEF\200925_SINTEF_sample-T5-M5_positionA3\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T7-M3_positionA1\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T6-M8_positionA5\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T2-M4_positionB5\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T7-M4_positionC2\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T7-M5_positionB4\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T7-M6_positionA7\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T5-M8_positionB7\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T5-M7_positionA4\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T5-M6_positionA2\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T5-M4_positionC1\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T2-M5_positionA6\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T6-M7_positionB2\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T5-M3_positionB1\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T2-M7_positionB3\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T2-M8_positionB8\interact.pep.xml F:\SINTEF\200925_SINTEF_sample-T2-M6_positionB6\interact.pep.xml
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M5_positionB4]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M8_positionB7]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M6_positionA2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M3_positionA1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T6-M8_positionA5]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M4_positionB5]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M3_positionB1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T6-M7_positionB2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M4_positionC2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M8_positionB8]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M6_positionA7]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M6_positionB6]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M5_positionA3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M7_positionA4]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M5_positionA6]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M4_positionC1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherDbAnnotate [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M7_positionB3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe database --annotate F:\SINTEF\2020-10-28-decoys-contam-AP-004_translations.fa.fas --prefix rev_
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M6_positionA7]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T7-M6_positionA7 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M8_positionB7]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T5-M8_positionB7 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M3_positionA1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T7-M3_positionA1 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T6-M7_positionB2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T6-M7_positionB2 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M5_positionA3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T5-M5_positionA3 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T6-M8_positionA5]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T6-M8_positionA5 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M4_positionC1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T5-M4_positionC1 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M3_positionB1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T5-M3_positionB1 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M8_positionB8]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T2-M8_positionB8 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M6_positionB6]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T2-M6_positionB6 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M6_positionA2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T5-M6_positionA2 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M5_positionA6]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T2-M5_positionA6 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M7_positionA4]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T5-M7_positionA4 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M4_positionC2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T7-M4_positionC2 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M4_positionB5]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T2-M4_positionB5 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M5_positionB4]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T7-M5_positionB4 --protxml F:\SINTEF\combined.prot.xml
PhilosopherFilter [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M7_positionB3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe filter --sequential --razor --prot 0.01 --mapmods --tag rev_ --pepxml F:\SINTEF\200925_SINTEF_sample-T2-M7_positionB3 --protxml F:\SINTEF\combined.prot.xml
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M8_positionB7]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M5_positionB4]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M6_positionA2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M3_positionA1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T6-M8_positionA5]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M4_positionB5]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M3_positionB1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T6-M7_positionB2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M8_positionB8]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M4_positionC2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M6_positionA7]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M6_positionB6]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M5_positionA3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M7_positionA4]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M5_positionA6]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M4_positionC1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherReport [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M7_positionB3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe report
PhilosopherAbacus [Work dir: F:\SINTEF]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe abacus --razor --reprint --tag rev_ --protein 200925_SINTEF_sample-T7-M6_positionA7 200925_SINTEF_sample-T5-M8_positionB7 200925_SINTEF_sample-T7-M3_positionA1 200925_SINTEF_sample-T2-M3_positionA8 200925_SINTEF_sample-T6-M7_positionB2 200925_SINTEF_sample-T5-M5_positionA3 200925_SINTEF_sample-T6-M8_positionA5 200925_SINTEF_sample-T5-M4_positionC1 200925_SINTEF_sample-T5-M3_positionB1 200925_SINTEF_sample-T2-M8_positionB8 200925_SINTEF_sample-T2-M6_positionB6 200925_SINTEF_sample-T5-M6_positionA2 200925_SINTEF_sample-T2-M5_positionA6 200925_SINTEF_sample-T5-M7_positionA4 200925_SINTEF_sample-T7-M4_positionC2 200925_SINTEF_sample-T2-M4_positionB5 200925_SINTEF_sample-T7-M5_positionB4 200925_SINTEF_sample-T2-M7_positionB3
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M8_positionB7]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M5_positionB4]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M6_positionA2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M3_positionA1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T6-M8_positionA5]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M4_positionB5]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M3_positionB1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T6-M7_positionB2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M8_positionB8]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M4_positionC2]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T7-M6_positionA7]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M6_positionB6]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M5_positionA3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M7_positionA4]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M5_positionA6]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T5-M4_positionC1]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
WorkspaceClean [Work dir: F:\SINTEF\200925_SINTEF_sample-T2-M7_positionB3]
C:\Users\animeshs\GD\fragpipe\tools\philosopher\philosopher.exe workspace --clean --nocheck
PTMShepherd [Work dir: F:\SINTEF]
java -Dbatmass.io.libs.thermo.dir="C:\Users\animeshs\GD\fragpipe\tools\MSFragger-3.1\ext\thermo" -cp "C:\Users\animeshs\GD\fragpipe\tools\ptmshepherd-0.4.0.jar;C:\Users\animeshs\GD\fragpipe\tools\batmass-io-1.19.5.jar;C:\Users\animeshs\GD\fragpipe\tools\commons-math3-3.6.1.jar" edu.umich.andykong.ptmshepherd.PTMShepherd "F:\SINTEF\shepherd.config"
~~~~~~~~~~~~~~~~~~~~~~

Execution order:

    Cmd: [START], Work dir: [F:\SINTEF]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M8_positionB7]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T7-M5_positionB4]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M6_positionA2]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T7-M3_positionA1]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T6-M8_positionA5]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M4_positionB5]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M3_positionB1]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T6-M7_positionB2]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M8_positionB8]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T7-M4_positionC2]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T7-M6_positionA7]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M6_positionB6]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M5_positionA3]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M7_positionA4]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M5_positionA6]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M4_positionC1]
    Cmd: [WorkspaceCleanInit], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M7_positionB3]
    Cmd: [MsFragger], Work dir: [F:\SINTEF]
    Cmd: [Crystal-C], Work dir: [F:\SINTEF]
    Cmd: [PeptideProphet], Work dir: [F:\SINTEF]
    Cmd: [ProteinProphet], Work dir: [F:\SINTEF]
    Cmd: [PhilosopherDbAnnotate], Work dir: [F:\SINTEF]
    Cmd: [PhilosopherFilter], Work dir: [F:\SINTEF]
    Cmd: [PhilosopherReport], Work dir: [F:\SINTEF]
    Cmd: [PhilosopherAbacus], Work dir: [F:\SINTEF]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M8_positionB7]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T7-M5_positionB4]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M6_positionA2]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T7-M3_positionA1]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T6-M8_positionA5]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M4_positionB5]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M3_positionB1]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T6-M7_positionB2]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M8_positionB8]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T7-M4_positionC2]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M3_positionA8]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T7-M6_positionA7]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M6_positionB6]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M5_positionA3]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M7_positionA4]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M5_positionA6]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T5-M4_positionC1]
    Cmd: [WorkspaceClean], Work dir: [F:\SINTEF\200925_SINTEF_sample-T2-M7_positionB3]
    Cmd: [PTMShepherd], Work dir: [F:\SINTEF]

~~~~~~~~~~~~~~~~~~~~~~

It's a dry-run, not running the commands.


Please cite:
(Regular searches) MSFragger: ultrafast and comprehensive peptide identification in mass spectrometry–based proteomics. Nat Methods 14:513 (2017)
(Open search) Identification of modified peptides using localization-aware open search. Nat Commun. 11:4065 (2020)
(Open search) Crystal-C: A Computational Tool for Refinement of Open Search Results. J. Proteome Res. 19.6:2511 (2020)
(Open search) PTM-Shepherd: analysis and summarization of post-translational and chemical modifications from open search results. bioRxiv. DOI: 10.1101/2020.07.08.192583 (2020)
(Glyco/labile search) Fast and comprehensive N- and O-glycoproteomics analysis with MSFragger-Glyco. Nat Methods DOI: 10.1101/2020.05.18.10266 (2020)
(timsTOF PASEF) Fast quantitative analysis of timsTOF PASEF data with MSFragger and IonQuant. Mol Cell Proteomics 19: 1575 (2020)
(PeptideProphet/ProteinProphet/PTMProphet/Filtering) Philosopher: a versatile toolkit for shotgun proteomics data analysis. Nat Methods 17:869 (2020)
(TMT-Integrator) Quantitative proteomic landscape of metaplastic breast carcinoma pathological subtypes and their relationship to triple-negative tumors. Nat Commun. 11:1723 (2020)
(DIA-Umpire) DIA-Umpire: comprehensive computational framework for data-independent acquisition proteomics. Nat Methods 12:258 (2015)

#https://github.com/Nesvilab/philosopher/wiki/Simple-Data-Analysis
#FragPipe version 13.0
#MSFragger version 3.0
#Philosopher version 3.2.9 (build 1593192429)
#Pseudomonas project
ln -s /mnt/z/PA
cd PA
$HOME/GD/fragpipe/philosopher workspace --clean --nocheck
$HOME/GD/fragpipe/philosopher workspace --init --nocheck
$HOME/GD/fragpipe/philosopher database --reviewed --contam --id  UP000002438
#java -jar $HOME/GD/fragpipe/MSFragger-3.0.jar fragger.open.params 140605_Pseudomonas_O1_K0K6.raw
#for in in *.raw ; do echo $i ; java -Xmx64G -jar $HOME/GD/fragpipe/MSFragger-3.0.jar fragger.open.params $i ; done
#sudo apt -y install parallel
find ./ -name "*.raw" | parallel -j 1 "java -jar $HOME/GD/fragpipe/MSFragger-3.0.jar fragger.open.params {}"
#java -jar -Dfile.encoding=UTF-8 -Xmx64G MSFragger-3.0.jar
for in in *.pepXML ; do echo $i; j=$(basename $i); echo $j ; k=${j%%.*} ; echo $k; mkdir $k ; mv $i $k/. ;mv $k.tsv $k/. ; done
for in in *.tsv ; do echo $i; j=$(basename $i); echo $j ; k=${j%%.*} ; echo $k; mkdir $k ; cp $i $k/. ; done
#java -cp fragpipe/lib/fragpipe-13.0.jar com.github.chhh.utils.FileMove PA/140605_Pseudomonas_O1_K0K6_T2.pepXML GD/Raw/140605_Pseudomonas_O1_K0K6_T2.pepXML
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
#EL
for i in /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/Data/Elite/*.raw ; do echo $i; j=$(basename $i); echo $j ; k=${j%%.*} ; echo $k; java -Xmx64g -jar ./MSFragger-3.0.jar ./open_fragger.params $i ; mkdir ./$k ; mv /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/Data/Elite/*.mgf  ./$k/. ; mv /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/Data/Elite/*.tsv  ./$k/. ; mv /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/Data/Elite/*.pepXML  ./$k/. ; cp -rf ./.meta  ./$k/. ; ls -ltrh   ./$k ; done

__fragger.open.params__
database_name = 2020-07-22-decoys-reviewed-contam-UP000002438.fas
num_threads = 12  # 0=poll CPU to set num threads; else specify num threads directly (max 64)
precursor_mass_lower = -150
precursor_mass_upper = 500
precursor_mass_units = 0			# 0=Daltons, 1=ppm, 3=DIA, 2=DIA_MS1
precursor_true_tolerance = 10
precursor_true_units = 1			# 0=Daltons, 1=ppm
fragment_mass_tolerance = 0.5
fragment_mass_units = 0			# 0=Daltons, 1=ppm
calibrate_mass = 2			# 0=Off, 1=On, 2=On and find optimal parameters
decoy_prefix = rev_

deisotope = 1
isotope_error = 0			# 0=off, -1/0/1/2/3 (standard C13 error)
mass_offsets = 0			# allow for additional precursor mass window shifts. Multiplexed with isotope_error. mass_offsets = 0/79.966 can be used as a restricted ‘open’ search that looks for unmodified and phosphorylated peptides (on any residue)
precursor_mass_mode = selected

remove_precursor_peak = 0			# 0 = not remove, 1 = only remove the peak with the precursor charge, 2 = remove all peaks with all charge states. Default: 0
remove_precursor_range = -1.50,1.50			# Unit: Da. Default: -1.5,1.5
intensity_transform = 0			# 0 = none, 1 = sqrt root. Default: 0

write_calibrated_mgf = 1			# Write calibrated MS2 scan to a MGF file (0 for No, 1 for Yes).
mass_diff_to_variable_mod = 0			# Put mass diff as a variable modification. 0 for no; 1 for yes and change the original mass diff and the calculated mass accordingly; 2 for yes but not change the original mass diff and the calculated mass.

localize_delta_mass = 1
delta_mass_exclude_ranges = (-1.5,3.5)
fragment_ion_series = b,y
ion_series_definitions =

labile_search_mode = off			# options: "off", "nglycan", "labile" (default: off)
deltamass_allowed_residues = ST			# aminoacids that are allowed to be modified in Glyco mode. E.g. "ST"
diagnostic_intensity_filter = 0			# possible values are 0 <= x <= 1
Y_type_masses = 0/203.07937/406.15874/568.21156/730.26438/892.3172/349.137279
diagnostic_fragments = 204.086646/186.076086/168.065526/366.139466/144.0656/138.055/126.055/163.060096/512.197375/292.1026925/274.0921325/657.2349/243.026426/405.079246/485.045576/308.09761

search_enzyme_name = trypsin
search_enzyme_cutafter = KR
search_enzyme_butnotafter = P

num_enzyme_termini = 2			# 2 for enzymatic, 1 for semi-enzymatic, 0 for nonspecific digestion
allowed_missed_cleavage = 1			# maximum value is 5

clip_nTerm_M = 1

#maximum of 7 mods - amino acid codes, * for any amino acid, [ and ] specifies protein termini, n and c specifies peptide termini
variable_mod_01 = 15.99490 M 3
variable_mod_02 = 42.01060 [^ 1
# variable_mod_03 = 79.96633 STY 3
# variable_mod_04 = -17.02650 nQnC 1
# variable_mod_05 = -18.01060 nE 1
# variable_mod_06 = 0.00000 site_06 1
# variable_mod_07 = 0.00000 site_07 1
# variable_mod_08 = 0.00000 site_08 1
# variable_mod_09 = 0.00000 site_09 1
# variable_mod_10 = 0.00000 site_10 1
# variable_mod_11 = 0.00000 site_11 1
# variable_mod_12 = 0.00000 site_12 1
# variable_mod_13 = 0.00000 site_13 1
# variable_mod_14 = 0.00000 site_14 1
# variable_mod_15 = 0.00000 site_15 1
# variable_mod_16 = 0.00000 site_16 1

allow_multiple_variable_mods_on_residue = 0			# static mods are not considered
max_variable_mods_per_mod = 3
max_variable_mods_per_peptide = 3			# maximum 5
max_variable_mods_combinations = 5000			# maximum 65534, limits number of modified peptides generated from sequence

output_file_extension = pepXML
output_format = pepXML
output_report_topN = 1
output_max_expect = 50
report_alternative_proteins = 1			# 0=no, 1=yes

precursor_charge = 1 4			# precursor charge range to analyze; does not override any existing charge; 0 as 1st entry ignores parameter
override_charge = 0			# 0=no, 1=yes to override existing precursor charge states with precursor_charge parameter

digest_min_length = 7
digest_max_length = 50
digest_mass_range = 500.0 5000.0			# MH+ peptide mass range to analyze
max_fragment_charge = 2			# set maximum fragment charge state to analyze (allowed max 5)

#open search parameters
track_zero_topN = 0			# in addition to topN results, keep track of top results in zero bin
zero_bin_accept_expect = 0.00			# boost top zero bin entry to top if it has expect under 0.01 - set to 0 to disable
zero_bin_mult_expect = 1.00			# disabled if above passes - multiply expect of zero bin for ordering purposes (does not affect reported expect)
add_topN_complementary = 0

# spectral processing

minimum_peaks = 15			# required minimum number of peaks in spectrum to search (default 10)
use_topN_peaks = 100
min_fragments_modelling = 2
min_matched_fragments = 4
minimum_ratio = 0.01			# filter peaks below this fraction of strongest peak
clear_mz_range = 0.0 0.0			# for iTRAQ/TMT type data; will clear out all peaks in the specified m/z range

# additional modifications

add_Cterm_peptide = 0.000000
add_Nterm_peptide = 0.000000
add_Cterm_protein = 0.000000
add_Nterm_protein = 0.000000

add_G_glycine = 0.000000
add_A_alanine = 0.000000
add_S_serine = 0.000000
add_P_proline = 0.000000
add_V_valine = 0.000000
add_T_threonine = 0.000000
add_C_cysteine = 57.021464
add_L_leucine = 0.000000
add_I_isoleucine = 0.000000
add_N_asparagine = 0.000000
add_D_aspartic_acid = 0.000000
add_Q_glutamine = 0.000000
add_K_lysine = 0.000000
add_E_glutamic_acid = 0.000000
add_M_methionine = 0.000000
add_H_histidine = 0.000000
add_F_phenylalanine = 0.000000
add_R_arginine = 0.000000
add_Y_tyrosine = 0.000000
add_W_tryptophan = 0.000000
add_B_user_amino_acid = 0.000000
add_J_user_amino_acid = 0.000000
add_O_user_amino_acid = 0.000000
add_U_user_amino_acid = 0.000000
add_X_user_amino_acid = 0.000000
add_Z_user_amino_acid = 0.000000
