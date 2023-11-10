# docker pull docker.io/animesh1977/scripts
# base https://github.com/UNINETTSigma2/helm-charts-dockerfiles/blob/05c68273357e38481591058b2ef1d6ef2549dd9c/deep-learning-tools2/Dockerfile https://github.com/UNINETTSigma2/helm-charts-dockerfiles/tree/05c68273357e38481591058b2ef1d6ef2549dd9c/jupyter-spark https://quay.io/repository/nird-toolkit/deep-learning-tools2?tab=history 
# get tag from https://quay.io/repository/nird-toolkit/deep-learning-tools2?tab=history https://hub.docker.com/r/thtb2access/deep-learning-tools2/tags
FROM quay.io/nird-toolkit/deep-learning-tools2:20230823-211329a
# download the repo: git clone scripts
# move into the cloned directory: cd scripts
# create image with CMD:  docker build --no-cache .
# list:	docker image ls
# tag:	docker tag 6586148049a0 animesh1977/scripts
# load:	docker push animesh1977/scripts
# Install packages
USER root
# os-version: cat /etc/os-release
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update 
RUN apt-get install -y psmisc parallel gnupg ca-certificates apt-transport-https gnupg ca-certificates curl dotnet-sdk-3.1
#example test MaxQuant within created container
#docker run -it --privileged 6586148049a0 /bin/bash
#wget "https://maxquant.org/p/maxquant/MaxQuant_2.4.0.0.zip?md5=qSckER_24nPBpRR3Ar5A7Q&expires=1683877801" -O MQ.zip #link from https://www.maxquant.org/download_asset/maxquant/latest
#unzip MQ.zip
#rm mqpar.xml 
#dotnet $PWD/MaxQuant*/bin/MaxQuantCmd.exe -c mqpar.xml
#wget "https://rest.uniprot.org/uniprotkb/stream?format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000005640%29%29" -O uniprot_human_iso_$(date +%d%b%Y).fasta
#sed "s?example.fasta?$PWD/uniprot_human_iso_$(date +%d%b%Y).fasta?" mqpar.xml  > mqpar.cf.xml
#wget https://github.com/animesh/RawRead/raw/master/171010_Ip_Hela_ugi.raw
#sed "s?file.example.RAW?$PWD/171010_Ip_Hela_ugi.raw?" mqpar.cf.xml  > mqpar.xml
#dotnet $PWD/MaxQuant*/bin/MaxQuantCmd.exe $PWD/mqpar.xml
#grep "Q5JVX7" combined/txt/proteinGroups.txt | awk '{print $1,$20}'#11.746
