FROM redhat/ubi8:8.4

ENV TERM="xterm-256color"
ARG PKG_DEPS="unzip git wget curl dirmngr gnupg2 binutils net-tools man ca-certificates vim-enhanced policycoreutils-python-utils.noarch"
ARG ZULU_JDK_TARBALL_URI='https://cdn.azul.com/zulu/bin/zulu8.68.0.21-ca-jdk8.0.362-linux_x64.tar.gz'

RUN echo "alias vi=vim"
RUN echo 'set -g default-terminal "screen-256color"' >> ~/.tmux.conf
RUN yum install -y ${PKG_DEPS} && yum update -y

RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes
RUN mkdir ~/.config/
RUN wget -L https://raw.githubusercontent.com/Jonathan-Zollinger/PeanutButter-Unicorn/main/config-linux/starship.toml -o ~/.config/starship.toml -o ~/.config/starship.toml
RUN echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc
RUN echo "alias ls='ls --color'" | tee -a ~/.bashrc

WORKDIR /opt/netiq/idm/apps/Tomcat
COPY . .
RUN [[ "$(ls)"=~"jdk8" ]] && echo "jdk 8 present, alternate tarball is not produced" || wget ${ZULU_JDK_TARBALL_URI}



CMD ["/bin/bash"] 
