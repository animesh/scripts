# Switch to Linux containers then instruction https://ropenscilabs.github.io/r-docker-tutorial/04-Dockerhub.html
# clean: docker system prune
# create image with CMD:  "docker build --no-cache ."
# name:   "docker tag 262985e2d4cb animesh1977/scripts"
# upload: "docker push animesh1977/scripts"
# docker run -it --privileged 262985e2d4cb /bin/bash
# Image name from https://github.com/Uninett/helm-charts/blob/master/repos/stable/deep-learning-tools/values.yaml
FROM quay.io/uninett/deep-learning-tools:20200713-479878a
# Install system packages
USER root
RUN apt-get update && apt-get install -y vim psmisc openssh-server parallel
# cat /etc/os-release
# install mono https://www.mono-project.com/download/stable/#download-lin
RUN apt install -y gnupg ca-certificates
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
RUN apt update
RUN apt install -y mono-devel
# install dotnet-3.1 https://tecadmin.net/how-to-install-dotnet-core-on-ubuntu-18-04/ for MaxQuant 2.0.3.0
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN sudo dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb
RUN sudo apt-get update
RUN sudo apt-get install -y apt-transport-https 
RUN sudo apt-get update 
RUN sudo apt-get install -y dotnet-sdk-3.1
# pip pkgs
RUN pip install --upgrade pip
#RUN pip install tensorflow_decision_forests
RUN pip install ipyvolume
RUN jupyter nbextension enable --py --sys-prefix ipyvolume
#RUN jupyter lab build
#packages for R
#RUN R -e "update.packages(ask = FALSE,repos='http://cran.us.r-project.org')"
RUN R -e "install.packages(c('devtools','BiocManager'),dependencies=TRUE,repos='https://cloud.r-project.org/',ask=FALSE,INSTALL_opts = '--no-multiarch')"
#RUN R -e "devtools::install_github('bartongroup/Proteus', build_opts= c('--no-resave-data', '--no-manual'), build_vignettes=F)"
#RUN R -e "install.packages(c('readxl','writexl','ggplot2','svglite','scales'),dependencies=TRUE,repos='https://cloud.r-project.org/',ask=FALSE,INSTALL_opts = '--no-multiarch')"
#RUN R -e "BiocManager::install(c('pheatmap','limma','org.Hs.eg.db'))"
