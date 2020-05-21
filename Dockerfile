FROM ubuntu:focal-20200423

# To avoid tzdata installation 'issue': https://serverfault.com/questions/949991/how-to-install-tzdata-on-a-ubuntu-docker-image
RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Install linux tools binaries with apt-get
RUN apt-get update \
 && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
                   sudo \
                   curl \
                   wget \
                   make \
                   pwgen \
                   git \
                   gnupg \
                   lsb-release \
                   software-properties-common \
 && sudo apt autoremove \
 && rm -rf /var/lib/apt/lists/*

ARG ARCH=amd64

# Install docker-ce, according to https://docs.docker.com/engine/install/ubuntu/
# Installing docker 19.03.9 client may produce "Error response from daemon: client version 1.40 is too new. Maximum supported API version is 1.39" error with docker server 18.09.3,
# which is the max docker version of CircleCI, according to https://circleci.com/docs/2.0/building-docker-images/), as discussed via
# https://github.com/kubernetes-sigs/kubespray/issues/6160. So we want to stick to 19.03.8.
# But on the docker repo of ubuntu focal, there is only "19.03.9".
# To check this, compare these 2 URLs:
#  - https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64/
#  - https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/
# So let's use the "bionic" ubuntu repo !
#
# !!!!! SHOULD_DO !!!!! (in the future, when upgrading docker):
# Replace add-apt-repository "deb [arch=${ARCH}] https://download.docker.com/linux/ubuntu bionic stable" \
# to      add-apt-repository "deb [arch=${ARCH}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
 && add-apt-repository "deb [arch=${ARCH}] https://download.docker.com/linux/ubuntu bionic stable" \
 && apt-get update \
 && apt-cache madison docker-ce-cli \
 && DEBIAN_FRONTEND="noninteractive" sudo apt-get install -y \
                   docker-ce-cli=5:19.03.8* \
 && sudo apt autoremove \
 && rm -rf /var/lib/apt/lists/*

# RUN sudo apt-get -y -o Dpkg::Options::="--force-confnew" install docker-ce
# In docker 19.03.8 is installed via "apt-get install docker.io", "buildx" is not working "out of the box".
# Next code was supposed to fix this (but it does not)
# It is not an issue as soon as we use docker-ce install, as docker-ce comes out-of-the-box with buildx plugin
# See:
#  -
# RUN mkdir -p "~/.docker/cli-plugins" \
#  && wget -O "~/.docker/cli-plugins/docker-buildx" "https://github.com/docker/buildx/releases/download/v0.4.1/buildx-v0.4.1.linux-${ARCH}" \
#  && chmod +x "~/.docker/cli-plugins/docker-buildx"

# Quick docker install smoke tests:
RUN docker --version
RUN DOCKER_CLI_EXPERIMENTAL=enabled docker buildx version

ARG BUILD_DATE
ARG VCS_REF
LABEL \
	org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.vcs-ref=$VCS_REF \
	org.label-schema.vcs-url="https://github.com/biarms/docker-toolbox"
