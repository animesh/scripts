#python motifSeqAlign.py /home/ash022/Animesh/Motif/uniprot_sprot.motif.found.seq.txtEnolase\ .csv /mnt/f/structue/
#cp -rf /mnt/f/structue/*.png /home/ash022/promec/promec/Animesh/Motif/enolase/Enolase/.
#tar cvf structures.tar /mnt/f/structue/*.png
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
#gunzip uniprot_sprot.fasta.gz
#perl motif.pl uniprot_sprot.fasta "[RK][FWY][ALVI][GALVI][RK]" | awk -F '\t' '$3!=""' > uniprot_sprot.motif.found.seq.txt
#Rscript motifSeqAlign.r  L:\promec\Animesh\Motif\uniprot_sprot.motif.found.seq.txt "Valine--tRNA ligase"
#https://alphafold.ebi.ac.uk/download
#wget https://ftp.ebi.ac.uk/pub/databases/alphafold/latest/swissprot_pdb_v4.tar
# %%setup
#git clone https://github.com/schrodinger/pymol-open-source
#cd pymol-open-source/
#sudo apt update
#sudo apt install cmake netcdf-bin libnetcdf-dev libglm-dev libglew-dev libpng-dev libfreetype-dev libfreetype6 libfreetype6-dev
#pip install .
#sudo apt install qtcreator qtbase5-dev qt5-qmake cmake pyqt5-dev pyqt5-dev-tools python3-pyqt5
#qtchooser -run-tool=designer -qt=5 #test
#cat  /usr/lib/x86_64-linux-gnu/qt-default/qtchooser/default.conf
#/usr/lib/qt5/bin
#/usr/lib/x86_64-linux-gnu
#pip install pyqt5
#https://stackoverflow.com/a/52629123
#wget https://alphafold.ebi.ac.uk/files/AF-P26640-F1-model_v4.pdb
#for protein in *.pdb; do pymol -cq $protein -d "hide everything;show ribbon;select motif, resi 957-962; show cartoon, motif;color red, motif; zoom center, 50;png $protein.png, width=25cm, dpi=150, ray=1"; done
#https://pymolwiki.org/index.php/Launching_From_a_Script
#moddir='/opt/miniconda/lib/python3.11/site-packages'
#sys.path.insert(0, moddir)
#os.environ['PYMOL_PATH'] = os.path.join(moddir, 'pymol/pymol_path')
# pymol launching: quiet (-q), without GUI (-c) and with arguments from command line
# %% input
import sys
motifFile = sys.argv[1]
#motifFile = "/home/ash022/Animesh/Motif/uniprot_sprot.motif.found.seq.txtEnolase .csv"
pathPDB = sys.argv[2]
#pathPDB = "/mnt/f/structue/"
# %% load motifs
import pandas as pd
motifList = pd.read_csv(motifFile)
motifList=motifList.fillna("NA")
print(motifList.head(),motifList.columns)
# %% data
fileNameList=motifList['Uniprot']
pdbFileList=pathPDB+"AF-"+motifList['Uniprot']+"-F1-model_v4.pdb.gz"
pdbFileRes='_'+motifList['Gene']+'_'+motifList['UnID']+motifList['Species']
# %% load motifs
import os
for cnt in range(len(pdbFileList)):
  print(cnt)
  pdbFile=pdbFileList[cnt]
  if not os.path.exists(pdbFile):
    print(f"File {pdbFile} does not exist.")
    continue
  print(pdbFile)
  # %% load pdb file
  import __main__
  __main__.pymol_argv = [ 'pymol', '-qc']
  import pymol
  pymol.finish_launching()  # not supported on macOSimport sys,os
  from pymol import cmd
  # %% load pymol
  # %% load pdb file
  #pdbFile = "AF-P26640-F1-model_v4.pdb"
  #pdbFile = "/mnt/f/structue/AF-A0L408-F1-model_v4.pdb.gz"
  cmd.load(pdbFile)
  # %% show
  cmd.hide('everything')
  cmd.show('cartoon')
  cmd.color('green')
  # %% motif
  #https://pymolwiki.org/index.php/Label
  #https://pymolwiki.org/index.php/Label_position
  #cmd.set('label_position', '1 1 1')
  #cmd.pseudoatom('motifStr')
  #cmd.label('motifStr','\"motifStr\"')
  #P93736 RFAAR,465-470;KFLGK,604-609;
  motifs=motifList['X.RK..FWY..ALVI..GALVI..RK..found.as.Sequence.s..Position.s.0.for.1st..'][cnt].split(';')
  #motif=motifs[0]
  #from joblib import Parallel, delayed
  for motif in motifs:
      if motif == '':
          continue
      motifPos = 'resi '+str(int(motif.split(',')[1].split('-')[0])+1)+'-'+motif.split(',')[1].split('-')[1]
      motifLabel = 'n. CA and i. '+ str(int(motif.split(',')[1].split('-')[0])+1)+'-'+motif.split(',')[1].split('-')[1]
      motifSeqPos = 'n. CA and i. '+ str(int(motif.split(',')[1].split('-')[1])+1)
      motifSequence = '\"'+motif.split(',')[0]+'\"'
      cmd.select('motif', motifPos)
      cmd.show('cartoon', 'motif')
      cmd.set('label_font_id', '10')
      cmd.set('label_size', '7')
      cmd.set('label_color', 'white')
      cmd.label(motifLabel,'resi')
      cmd.label(motifSeqPos,motifSequence)
      cmd.color('red', 'motif')
      #motifPos = 'resi '+str(int(motifList['X.RK..FWY..ALVI..GALVI..RK..found.as.Sequence.s..Position.s.0.for.1st..'][cnt].split(';')[0].split(',')[1].split('-')[0])+1)+'-'+str(int(motifList['X.RK..FWY..ALVI..GALVI..RK..found.as.Sequence.s..Position.s.0.for.1st..'][cnt].split(';')[0].split(',')[1].split('-')[1]))
      #motifLabel = 'n. CA and i. '+ motifList['X.RK..FWY..ALVI..GALVI..RK..found.as.Sequence.s..Position.s.0.for.1st..'][cnt].split(';')[0].split(',')[1]
      #motifSeqPos = 'n. CA and i. '+ str(int(motifList['X.RK..FWY..ALVI..GALVI..RK..found.as.Sequence.s..Position.s.0.for.1st..'][cnt].split(';')[0].split(',')[1].split('-')[1])+1)
      #motifSequence = '\"'+motifList['X.RK..FWY..ALVI..GALVI..RK..found.as.Sequence.s..Position.s.0.for.1st..'][cnt].split(';')[0].split(',')[0]+'\"'
      #cmd.select('motif', motifPos)
      #cmd.show('cartoon', 'motif')
      #cmd.set('label_font_id', '10')
      #cmd.set('label_size', '7')
      #cmd.set('label_color', 'white')
      #cmd.label(motifLabel,'resi')
      #cmd.color('red', 'motif')
      #cmd.label(motifSeqPos,motifSequence)
      #motifPos = 'resi 605-609'
      #motifLabel = 'n. CA and i. 605-609'
      #motifSeqPos = 'n. CA and i. 609'
      #motifSequence = '\"KFLGK\"'
      #cmd.select('motif', motifPos)
      #cmd.show('cartoon', 'motif')
      #cmd.set('label_font_id', '10')
      #cmd.set('label_size', '7')
      #cmd.set('label_color', 'white')
      #cmd.label(motifLabel,'resi')
      #cmd.pseudoatom('motifStr')
      #cmd.label('motifStr','\"motifStr\"')
      #cmd.label(motifSeqPos,motifSequence)
      #cmd.color('red', 'motif')
  cmd.zoom('center', 50)
  pngFile=pdbFile+pdbFileRes[cnt]+'_'+str(cnt+1)+'.png'
  cmd.png(pngFile,1600, 1200, dpi=150, ray=1)
  print(pngFile)
  cmd.remove('all')
  #cmd.quit()
  #cmd._quit()
  #cmd.abort()

  # %%
