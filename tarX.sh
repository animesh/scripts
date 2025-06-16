#!/bin/bash
ls /projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240222_DIA/DIA_library/*.d
grep 240222_Maike_DIAlib_waste_Slot2-2_1_6569.d $HOME/disc/NS9036K/promec/*.log
for i in /projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240222_DIA/DIA_library/*.d ; do echo $i; tar -xvf  $HOME/disc/NS9036K/promec/backup.02_23_2024.tar.gz  "projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/Raw/LARS/240222_DIA/"$(basename $i) --checkpoint=.1000000; done
