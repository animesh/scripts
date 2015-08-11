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
