mkdir tes
tar cvf t.tar *.txt *.log
tar -xf $PWD/t.tar -C $PWD/tes/ --wildcards --ignore-case "*.txt"
for i in /nird/projects/NS9036K/NORSTORE_OSL_TAPE/PROMECBkUp/*.tar.gz ; do echo $i;  tar -xvzf $i -C /nird/projects/NS9036K/taraw/ --wildcards --ignore-case "*.raw" ; done
find /nird/home/ash022/promec/NORSTORE_OSL_DISK/NS9036K/promec/promec/ -iname "*.raw" -exec cp "{}" DL/orbitrap/ \;
ls DL/orbitrap/ | wc #19077 
find /nird/home/ash022/promec/NORSTORE_OSL_DISK/NS9036K/promec/promec/USERS/ -iname "*.raw" -exec cp "{}" DL/orbitrap/ \;
find /nird/home/ash022/promec/NORSTORE_OSL_DISK/NS9036K/promec/promec/Elite/ -iname "*.raw" -exec cp "{}" DL/orbitrap/ \;
find /nird/home/ash022/promec/NORSTORE_OSL_DISK/NS9036K/promec/promec/Qexactive/ -iname "*.raw" -exec cp "{}" DL/orbitrap/ \;
find /nird/home/ash022/promec/NORSTORE_OSL_DISK/NS9036K/promec/promec/HF/ -iname "*.raw" -exec cp "{}" DL/orbitrap/ \;

