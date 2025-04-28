mkdir tes
tar cvf t.tar *.txt *.log
tar -xf $PWD/t.tar -C $PWD/tes/ --wildcards --ignore-case "*.txt"
cd tes
ssh-copy-id 'ash022@login0.nird-lmd.sigma2.no'
sftp 'ash022@login0.nird-lmd.sigma2.no'
#Connected to login0.nird-lmd.sigma2.no.
#sftp> get -a *.txt
find PD/ -iname "*220218_CVID_11*.d"
ls -1d PD/Qexactive/Mirta/MariKarbo_CVID_2022/RawData/*.d | wc
#     63      63    5022
for i in  PD/Qexactive/Mirta/MariKarbo_CVID_2022/RawData/*.d ; do echo $i ; tar cvf  $i.tar  $i ; done
rm PD/Qexactive/Mirta/MariKarbo_CVID_2022/RawData/combined/txt.tar*
for i in  PD/Qexactive/Mirta/MariKarbo_CVID_2022/RawData/combined/txt* ; do echo $i ; tar cvf  $i.tar  $i ; done
eval $(ssh-agent);ssh-add;rclone copy --include "/*.tar" -Pv NS9036K:PD/Qexactive/Mirta/MariKarbo_CVID_2022/RawData/ promec/promec/Qexactive/Mirta/MariKarbo_CVID_2022/RawData/
