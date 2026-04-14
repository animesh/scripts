#dos2unix scratch.slurm  slurmDIANN.sh
#bash slurmDIANN.sh /cluster/projects/nn9036k/scripts/steven2
#wget "https://release-assets.githubusercontent.com/github-production-release-asset/125283280/c0bccb38-eaa1-4ffc-b752-bb9f361df10e?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-04-14T09%3A29%3A27Z&rscd=attachment%3B+filename%3DDIA-NN-2.5.0-Academia-Linux.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-04-14T08%3A28%3A54Z&ske=2026-04-14T09%3A29%3A27Z&sks=b&skv=2018-11-09&sig=YtZ8jai1sTb1IP62AqWjnXIyF7XSQ%2FPFZrknDv34PDU%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3NjE1ODk2MSwibmJmIjoxNzc2MTU1MzYxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.fs2C_SJgzZyZazFqJW16GKH0RQVboLPU7xJ8R9H4BgY&response-content-disposition=attachment%3B%20filename%3DDIA-NN-2.5.0-Academia-Linux.zip&response-content-type=application%2Foctet-stream" -O DIANNv2p5.zip
# sha256sum DIANNv2p5.zip #https://github.com/vdemichev/DiaNN/releases/tag/2.0 05268fb6c778471beb46583400c862529b8ee452a620bb8bfdc8e9cc42eaf695
# unzip DIANNv2p5.zip 
#cp /cluster/projects/nn9036k/diann-2.3.2/camprotR_240512_cRAP_20190401_full_tags.fasta  /cluster/home/ash022/cluster/diann-2.5.0
#rsync -Parv TIMSTOF/LARS/2026/260408_Steven/*.d steven2/
#rsync -Parv TIMSTOF/LARS/2026/260408_Steven/libV2p5mc2v3dNQ.predicted.speclib steven2/
#rsync -Parv TIMSTOF/LARS/2026/260408_Steven/*.fasta steven2/
#for i in $PWD/maike/*.d ; do grep "TestFile.d" ; sed -i "s|TestFile\.d|$i|g" $i.slurm  ;done
DATADIR=$1
SEARCHTEXT=TestFile.d
CURRENTEPOCTIME=`date +%s`
WRITEFILE=$CURRENTEPOCTIME.report
echo $WRITEFILE
for i in $DATADIR/*.d ; do echo $i ; sed "s|$SEARCHTEXT|$i|g" scratch.slurm > $i.$WRITEFILE.tmp  ; sed "s|WRITEFILE|$WRITEFILE|g" $i.$WRITEFILE.tmp > $i.$WRITEFILE.slurm  ; sbatch $i.$WRITEFILE.slurm ; done
echo $WRITEFILE
ls -ltrh $DATADIR/*$WRITEFILE.slurm 
squeue -u ash022
#rsync -Parv steven2/*.report.* /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2026/260408_Steven/

