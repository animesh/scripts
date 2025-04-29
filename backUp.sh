mkdir tes
tar cvf t.tar *.txt *.log
tar -xf $PWD/t.tar -C $PWD/tes/ --wildcards --ignore-case "*.txt"
cd tes
ssh-copy-id 'ash022@login0.nird-lmd.sigma2.no'
sftp 'ash022@login0.nird-lmd.sigma2.no'
#Connected to login0.nird-lmd.sigma2.no.
#sftp> get -a *.txt
find PD/Qexactive/Mirta/ -iname "*20210309_CVID_1180*"
ls -1 PD/Qexactive/Mirta/MariKaarbo/*.raw | wc
#     37      37    1973
tar cvf PD/Qexactive/Mirta/MariKaarbo/txt.tar PD/Qexactive/Mirta/MariKaarbo/combined/txt
mkdir -p promec/promec/Qexactive/Mirta/MariKaarbo/
eval $(ssh-agent);ssh-add;rclone copy --include "/*.raw" -Pv NS9036K:PD/Qexactive/Mirta/MariKaarbo/  promec/promec/Qexactive/Mirta/MariKaarbo/
eval $(ssh-agent);ssh-add;rclone copy --include "/*.tar" -Pv NS9036K:PD/Qexactive/Mirta/MariKaarbo/  promec/promec/Qexactive/Mirta/MariKaarbo/
