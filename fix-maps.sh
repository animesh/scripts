#!/bin/sh

rm -f t.sed
touch t.sed
for f in seq*name
do b=`basename $f name`
   #n=$(cat $f | pip-quote-ps-string)
   n=` cat $f | tr -d '\r\n' | tr -c 'a-zA-Z0-9 ' '_' `
   test -n "${n}" && echo "s/${b}data/${n}/" >>t.sed
done
sed -f t.sed

#!/bin/sh
for x in *; do
	y=`echo $x | tr '[A-Z]' '[a-z]'`
	if [ $x != $y ]; then
		mv $x $y
	fi
done
	

	# 1:50 pm 4/26/97
# fixpath file
# fix iconx path in UNIX executable
for f in $*;do
ex $f <<\END
/iconx/
.,+s/.usr.home.rhm.icon/$KEHOME/
wq
END
done
