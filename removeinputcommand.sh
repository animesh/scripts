for a in *; do cp $a $a.NEW; done
for a in *.NEW
do
  b=`basename $a .NEW`
  sed -e '/%input featpost2D;/d' $a > $b
#  echo $a ----- $b
done
rm *.NEW

