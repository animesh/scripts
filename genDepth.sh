# wget -c https://github.com/HuiyangYu/PanDepth/releases/download/v2.64.tar.gz
# tar zvxf PanDepth-2.26-Linux-x86_64.tar.gz
# ./PanDepth-2.26-Linux-x86_64/pandepth -i /cluster/projects/nn9036k/TK/TK92L006.markdup.sorted.9036k/TK/TK92L006.markdup.sorted.bam.pandepth.out
for i in /cluster/projects/nn9036k/TK/*.markdup.sorted.bam; do
    echo "Processing $i"
    ./PanDepth-2.26-Linux-x86_64/pandepth -i $i -o $i.pandepth
    echo "Output for $i generated."
done
#(base) [ash022@login-1.SAGA ~/scripts]$ for i in /cluster/projects/nn9036k/TK/*.markdup.sorted.bam.pandepth.chr.stat.gz ; do echo $i;   zcat $i | grep "^13" ; done
