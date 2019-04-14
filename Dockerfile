#Instruction from https://apps.sigma2.no/docs/about-packages/deep-learning-tools/about.html
#Image name from https://github.com/Uninett/helm-charts/blob/master/repos/stable/deep-learning-tools/values.yaml
FROM	quay.io/uninett/deep-learning-tools:20190319-4881294
# Install system packages
USER 	root
RUN 	apt-get update && apt-get install -y apt-utils vim psmisc openssh-server git-core clang libpython-dev libblocksruntime-dev python3-pip zsh tmux autojump jq
# install mono
RUN     apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN     apt-get install -y apt-transport-https
RUN     echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
RUN     apt-get update && apt-get install -y mono-devel
# install swift-jupyter
RUN	sudo pip3 install --upgrade pip
RUN	git clone https://github.com/google/swift-jupyter.git
RUN sudo pip3 install -r swift-jupyter/requirements.txt
RUN sudo pip3 install -r swift-jupyter/requirements_py_graphics.txt
# Install other packages
RUN	sudo pip3 install ipywidgets
RUN	sudo pip3 install ipyvolume
RUN	sudo pip3 install UMAP
# install swift-tensorflow
USER 	notebook
RUN	wget https://storage.googleapis.com/s4tf-kokoro-artifact-testing/latest/swift-tensorflow-DEVELOPMENT-ubuntu18.04.tar.gz
RUN	tar xvzf swift-tensorflow-DEVELOPMENT-ubuntu18.04.tar.gz
RUN	export PATH=$(pwd)/usr/bin:"${PATH}"
RUN python3 swift-jupyter/register.py --sys-prefix --swift-toolchain ./
#docker run -it --privileged <docker-id> /bin/bash
