# Instruction https://apps.sigma2.no/docs/custom-docker-image.html
# Docker image: docker.io/animesh1977/scripts #else universe
# Base image name from tag in https://github.com/Uninett/helm-charts/blob/master/repos/stable/deep-learning-tools/values.yaml
FROM  quay.io/uninett/deep-learning-tools:20200713-479878a
# Install system packages
USER  root
# reverting java and clang as image >20GB
RUN apt-get update && apt-get install -y apt-utils vim psmisc openssh-server parallel default-jdk
# pip update
RUN pip install --upgrade pip
RUN pip install ipyvolume ann-solo
# install mono
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN apt-get install -y apt-transport-https
RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
RUN apt-get update && apt-get install -y mono-devel
#packages for R
RUN R -e "update.packages(ask = FALSE,repos='https://cloud.r-project.org/')"
RUN R -e "install.packages(c('devtools','BiocManager','readxl','writexl','ggplot2','svglite','scales','tfprobability','reticulate'),dependencies=TRUE,repos='https://cloud.r-project.org/',ask=FALSE,INSTALL_opts = '--no-multiarch')"
RUN R -e "devtools::install_github('bartongroup/Proteus', build_opts= c('--no-resave-data', '--no-manual'), build_vignettes=F)"
RUN R -e "BiocManager::install(c('clusterProfiler','pheatmap','limma','org.Hs.eg.db'))"
# cleanup
RUN 	apt-get  -y autoremove
RUN 	apt-get  -y clean
# Switch to Linux containers then
# Instruction https://ropenscilabs.github.io/r-docker-tutorial/04-Dockerhub.html
# create image with CMD:  "docker build ."
# name:   "docker tag af1f4b381e12 animesh1977/scripts"
# upload: "docker push animesh1977/scripts"
# docker run -it --privileged af1f4b381e12 /bin/bash
