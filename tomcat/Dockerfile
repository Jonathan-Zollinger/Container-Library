FROM redhat/ubi8:8.4

ENV TERM="xterm-256color"
ARG PKG_DEPS="unzip git wget curl dirmngr gnupg2 binutils net-tools man ca-certificates vim-enhanced policycoreutils-python-utils.noarch"
ARG ZULU_JDK_TARBALL_URI='https://cdn.azul.com/zulu/bin/zulu8.68.0.21-ca-jdk8.0.362-linux_x64.tar.gz'

RUN echo "alias vi=vim"
RUN echo 'set -g default-terminal "screen-256color"' >> ~/.tmux.conf
RUN yum install -y ${PKG_DEPS} && yum update -y
WORKDIR /opt/netiq/idm/apps/Tomcat
COPY . .
RUN [[ "$(dir)" =~ "jdk8" ]] && echo "jdk 8 present, alternate tarball is not produced" || wget ${ZULU_JDK_TARBALL_URI}


CMD ["/bin/bash", "-l"] 
