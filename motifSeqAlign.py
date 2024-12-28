#python motifSeqAlign.py AF-P26640-F1-model_v4.pdb
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
#for protein in *.pdb; do pymol -cq $protein -d "hide everything;select motif, resi 1-500;show cartoon, motif;zoom center, 20;png $protein.png, width=10cm, dpi=150, ray=1"; done
#for protein in *.pdb; do pymol -cq $protein -d "select motif, resi 1-50;show surface, motif;png $protein.png, width=10cm, dpi=150, ray=1"; done
#for protein in *.pdb; do pymol -cq $protein -d "hide everything;show ribbon;select motif, resi 957-962;show cartoon, motif;color red, motif; zoom center, 50;png $protein.png, width=25cm, dpi=150, ray=1"; done
#for protein in *.pdb; do pymol -cq $protein -d "hide everything;show ribbon;select motif, resi 957-962; show cartoon, motif;color red, motif; zoom center, 50;disable 957-962;label ca, 957-962;png $protein.png, width=25cm, dpi=150, ray=1"; done
#  angles      cgo         ellipsoids  licorice    nonbonded   sticks     callback    dashes      everything  lines       ribbon      surface   cartoon     dihedrals   extent      mesh        slice       volume     cell        dots        labels      nb_spheres  spheres     wire      
#https://pymolwiki.org/index.php/Launching_From_a_Script
#moddir='/opt/miniconda/lib/python3.11/site-packages'
#sys.path.insert(0, moddir)
#os.environ['PYMOL_PATH'] = os.path.join(moddir, 'pymol/pymol_path')
# pymol launching: quiet (-q), without GUI (-c) and with arguments from command line
import __main__
__main__.pymol_argv = [ 'pymol', '-qc']
import pymol
pymol.finish_launching()  # not supported on macOSimport sys,os
# %% load pdb file
from pymol import cmd
import sys
pdbFile = sys.argv[1]
cmd.load(pdbFile)
# %% show
cmd.hide('everything')
cmd.show('ribbon')
# %% motif
cmd.select('motif', 'resi 957-962')
cmd.show('cartoon', 'motif')
#https://pymolwiki.org/index.php/Label
cmd.set('label_color', 'green')
#https://pymolwiki.org/index.php/Label_position
#cmd.set('label_position', '1 1 1')
cmd.set('label_font_id', '10')
cmd.set('label_size', '8')
cmd.set('label_color', 'white')
cmd.label('n. CA and i. 957-962','resn')
cmd.color('red', 'motif')
cmd.zoom('center', 50)
cmd.png(pdbFile+'.pymol.png',1600, 1200, dpi=150, ray=1)
print(pdbFile+'.pymol.png')
