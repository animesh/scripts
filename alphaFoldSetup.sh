## hhblits

git clone https://github.com/animesh/hh-suite
mkdir -p hh-suite/build
cd hh-suite/build
cmake -DCMAKE_INSTALL_PREFIX=. ..
make -j 4 && make install
wget https://www.uniprot.org/uniprot/P13051.fasta
cat P13051.fasta >> P13051.msa.fasta
wget http://wwwuser.gwdg.de/~compbiol/uniclust/2018_08/uniclust30_2018_08_hhsuite.tar.gz
tar xvzf uniclust30_2018_08_hhsuite.tar.gz
bin/hhblits -cpu 12 -i  P13051.msa.fasta  -d uniclust30_2018_08/uniclust30_2018_08
python ../build/scripts/hhsuitedb.py --ihhm=~/promec/promec/Animesh/P13051.msa.hhr -o P13051.hhm  --cpu=12

## alphafold

python3 -m venv alphafold_venv
git clone https://github.com/animesh/deepmind-research.git
cd deepmind-research
source alphafold_venv/bin/activate
pip install wheel
pip install -r alphafold_casp13/requirements.txt
#./alphafold_casp13/run_eval.sh
#https://chrome.google.com/webstore/detail/curlwget/jmocjfidanebdlinpbcdkcmgdifblncg?hl=en
wget --header="Host: storage.googleapis.com" --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" --header="Accept-Language: en-IN,en;q=0.9,hi-IN;q=0.8,hi;q=0.7,nb-NO;q=0.6,nb;q=0.5,de-DE;q=0.4,de;q=0.3,en-GB;q=0.2,en-US;q=0.1" "https://storage.googleapis.com/alphafold_casp13_data/casp13_data.zip" -O "casp13_data.zip" -c
unzip casp13_data.zip
wget --header="Host: storage.googleapis.com" --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" --header="Accept-Language: en-IN,en;q=0.9,hi-IN;q=0.8,hi;q=0.7,nb-NO;q=0.6,nb;q=0.5,de-DE;q=0.4,de;q=0.3,en-GB;q=0.2,en-US;q=0.1" "https://storage.googleapis.com/alphafold_casp13_data/alphafold_casp13_weights.zip" -O "alphafold_casp13_weights.zip" -c
unzip alphafold_casp13_weights.zip
python3 -m alphafold_casp13.contacts --config_path=873731/0/config.json --checkpoint_path=873731/0/tf_graph_data/tf_graph_data.ckpt --output_path=chkout --eval_sstable=T1019s2/T1019s2.tfrec --stats_file=873731/stats_train_s35.json

## links

* [AlphaFold](https://deepmind.com/blog/article/AlphaFold-Using-AI-for-scientific-discovery)
* [Databases for the HH-suite](http://wwwuser.gwdg.de/~compbiol/data/hhsuite/)
