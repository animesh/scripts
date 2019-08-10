#Instruction from https://apps.sigma2.no/docs/custom-docker-image.html
#Image name from https://github.com/Uninett/helm-charts/blob/master/repos/stable/deep-learning-tools/values.yaml
FROM	quay.io/uninett/deep-learning-tools:20190628-fafa7e0
# Install system packages
USER 	root
#reverting java and clang as image >20GB
RUN 	apt-get update && apt-get install -y apt-utils vim psmisc openssh-server git-core libpython-dev libblocksruntime-dev python3-pip zsh tmux autojump jq parallel
# install mono
RUN     apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN     apt-get install -y apt-transport-https
RUN     echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
RUN     apt-get update && apt-get install -y mono-devel
# cleanup
RUN 	apt-get  -y autoremove
RUN 	apt-get  -y clean
#docker run -it --privileged <docker-id> /bin/bash
