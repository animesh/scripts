#cmd "docker build ."
#Instruction from https://ropenscilabs.github.io/r-docker-tutorial/04-Dockerhub.html
#tag "docker tag 9b29d94f85c4 animesh1977/uni"
#push "docker push animesh1977/uni"
#https://apps.sigma2.no/docs/custom-docker-image.html
#Base image name from tag in https://github.com/Uninett/helm-charts/blob/master/repos/stable/deep-learning-tools/values.yaml
FROM	quay.io/uninett/deep-learning-tools:20200713-479878a
# Install system packages
USER 	root
RUN conda install -c conda-forge xeus-python=0.8.0 notebook=6 jupyterlab=2 ptvsd nodejs  --yes #rdkit
RUN jupyter labextension install @jupyterlab/debugger
RUN jupyter labextension install jupyterlab-kernelspy
RUN jupyter labextension install @lckr/jupyterlab_variableinspector
#RUN jupyter labextension install jupyter-threejs
#RUN jupyter labextension install jupyterlab-datawidgets
#RUN conda update -n base conda
#reverting java and clang as image >20GB
RUN apt-get update && apt-get install -y apt-utils vim psmisc openssh-server parallel default-jdk tmux #git-core libpython-dev libblocksruntime-dev python3-pip zsh tmux autojump jq  libomp-dev libopenblas-base libsndfile1 libatlas-base-dev
#RUN pip install  colorama  vaex bqplot ipyvolume pythreejs #ann-solo faiss-gpu scipy librosa
#RUN jupyter nbextension enable --py --sys-prefix ipyvolume
#RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension
#RUN jupyter nbextension install --py --symlink --sys-prefix pythreejs
#RUN jupyter nbextension enable --py --sys-prefix pythreejs
#RUN jupyter lab build
# install mono
RUN     apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN     apt-get install -y apt-transport-https
RUN     echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
RUN     apt-get update && apt-get install -y mono-devel
# cleanup
RUN 	apt-get  -y autoremove
RUN 	apt-get  -y clean
#docker run -it --privileged <docker-id> /bin/bash
