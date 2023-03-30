# base https://github.com/UNINETTSigma2/helm-charts-dockerfiles/blob/05c68273357e38481591058b2ef1d6ef2549dd9c/deep-learning-tools2/Dockerfile https://github.com/UNINETTSigma2/helm-charts-dockerfiles/tree/05c68273357e38481591058b2ef1d6ef2549dd9c/jupyter-spark https://quay.io/repository/nird-toolkit/deep-learning-tools2?tab=history 
# get tag from https://quay.io/repository/nird-toolkit/deep-learning-tools2?tab=history https://hub.docker.com/r/thtb2access/deep-learning-tools2/tags
FROM quay.io/nird-toolkit/deep-learning-tools2:20230125-3292015
# download the repo: git clone scripts
# move into the cloned directory: cd scripts
# create image with CMD:  docker build --no-cache .
# list:	docker image ls
# bash:	docker run -it --privileged b0cf38d1d582 /bin/bash
# os-version: cat /etc/os-release
# tag:	docker tag 571dd20f71f7 animesh1977/scripts
# load:	docker push animesh1977/scripts
# docker pull docker.io/animesh1977/scripts
# Install system packages
USER root
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update 
RUN apt-get install -y psmisc parallel gnupg ca-certificates apt-transport-https gnupg ca-certificates curl dotnet-sdk-3.1
RUN wget "https://rest.uniprot.org/uniprotkb/stream?format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000005640%29%29" -O example.fasta
RUN wget https://github.com/animesh/RawRead/raw/master/171010_Ip_Hela_ugi.raw -O file.example.RAW
#RUN rm testfile
#download MaxQuant and test
#RUN wget "link from https://www.maxquant.org/download_asset/maxquant/latest" -O MQ.zip
#RUN unzip MQ.zip
#RUN dotnet $PWD/MaxQuant_v2.3.1.0/bin/MaxQuantCmd.exe -c mqpar.xml
#RUN dotnet $PWD/MaxQuant_v2.3.1.0/bin/MaxQuantCmd.exe mqpar.xml
#RUN rm mqpar.xml 
#RUN dotnet $PWD/MaxQuant_v2.2.0.0/MaxQuant_v2.2.0.0/bin/MaxQuantCmd.exe -c mqpar.xml
#RUN sed "s?example.fasta?$PWD/example.fasta?" mqpar.xml  > mqpar.cf.xml
#RUN sed "s?file.example.RAW?$PWD/file.example.RAW?" mqpar.cf.xml  > mqpar.xml
#RUN dotnet $PWD/MaxQuant_v2.2.0.0/MaxQuant_v2.2.0.0/bin/MaxQuantCmd.exe mqpar.xml