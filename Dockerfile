# docker pull docker.io/animesh1977/scripts
# latest: digest: sha256:4f47ea9ff5b442b29dbd97ab41074eb57c6a2c2d1fd0c848f270e9c82ba407fa
# base https://github.com/UNINETTSigma2/helm-charts-dockerfiles/blob/05c68273357e38481591058b2ef1d6ef2549dd9c/deep-learning-tools2/Dockerfile https://github.com/UNINETTSigma2/helm-charts-dockerfiles/tree/05c68273357e38481591058b2ef1d6ef2549dd9c/jupyter-spark https://quay.io/repository/nird-toolkit/deep-learning-tools2?tab=history 
# get tag from https://quay.io/repository/nird-toolkit/deep-learning-tools2?tab=history https://hub.docker.com/r/thtb2access/deep-learning-tools2/tags
FROM quay.io/nird-toolkit/deep-learning-tools2:20230823-211329a
# download the repo: git clone scripts
# move into the cloned directory: cd scripts
# create image with CMD:  docker build --no-cache .
# list:	docker image ls
# remove: docker image rm -f animesh1977/scripts
# create:	docker tag 4f47ea9ff5b4 animesh1977/scripts
# load:	docker push animesh1977/scripts
# Install packages
USER root
# os-version: cat /etc/os-release
RUN apt install ca-certificates gnupg
RUN gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
RUN apt update
RUN apt-get install -y psmisc parallel gnupg ca-certificates apt-transport-https gnupg ca-certificates curl mono-devel inotify-tools
#example test MaxQuant within created container
#docker run -it --privileged animesh1977/scripts /bin/bash
#link from https://www.maxquant.org/download_asset/maxquant/latest
#wget "https://maxquant.org/p/maxquant/MaxQuant_v_2.4.10.0.zip?md5=bwPYOvsI5oXolBP_wXUyzg&expires=1700127616" -O MQ.zip 
#unzip MQ.zip
#library
#wget "https://datashare.biochem.mpg.de/s/qe1IqcKbz2j2Ruf/download?path=%2FDiscoveryLibraries&files=homo_sapiens.zip" -O MQ_DIA.zip
#unzip MQ_DIA.zip
#wget https://github.com/animesh/RawRead/raw/master/171010_Ip_Hela_ugi.raw
#rm -rf mqpar.tmp.xml combined
#mono $PWD/MaxQuant*/bin/MaxQuantCmd.exe -c mqpar.tmp.xml
#sed "s?example.fasta?$PWD/UP000005640_9606.fasta?" mqpar.tmp.xml  > mqpar.tmp2.xml
#sed "s?file.example.RAW?$PWD/171010_Ip_Hela_ugi.raw?" mqpar.tmp2.xml  > mqpar.tmp.xml
#sed "s?Core>True?Core>False?" mqpar.tmp.xml  > mqpar.$(date +%d%b%Y).xml
#mono $PWD/MaxQuant*/bin/MaxQuantCmd.exe $PWD/mqpar.$(date +%d%b%Y).xml
#grep "ERAQRCFVSYVR" combined/txt/proteinGroups.txt | awk '{print $1,$21}'#7.0893
RUN rm -rf testfile