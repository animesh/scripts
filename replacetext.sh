for a in *; do mv $a `basename $a`.NEW; done
#for a in *.mp; do mv $a `basename $a mp`mpN; done
for a in *.NEW
 do sed -e 's/featpost3D/featpost3Dplus2D/' $a > `basename $a .NEW`
done
rm *.NEW

