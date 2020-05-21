FROM ubuntu:focal-20200423

# To avoid tzdata installation 'issue': https://serverfault.com/questions/949991/how-to-install-tzdata-on-a-ubuntu-docker-image
RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime

RUN apt-get update \
 && DEBIAN_FRONTEND="noninteractive" apt-get install -y sudo curl make gnupg lsb-release software-properties-common git pwgen docker.io=19.03.8* \
 && rm -rf /var/lib/apt/lists/*

ARG BUILD_DATE
ARG VCS_REF
LABEL \
	org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.vcs-ref=$VCS_REF \
	org.label-schema.vcs-url="https://github.com/biarms/pgadmin4"
