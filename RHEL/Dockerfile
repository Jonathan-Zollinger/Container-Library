FROM redhat/ubi8:8.4

ENV TERM="xterm-256color"

RUN echo -e "[charm]\nname=Charm\nbaseurl=https://repo.charm.sh/yum/\nenabled=1\ngpgcheck=1\ngpgkey=https://repo.charm.sh/yum/gpg.key" | tee /etc/yum.repos.d/charm.repo
ARG PKG_DEPS="unzip git wget curl dirmngr gnupg2 binutils net-tools glow skate gum man ca-certificates vim-enhanced policycoreutils-python-utils.noarch"

RUN yum install -y ${PKG_DEPS} && yum update -y

RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes
RUN mkdir ~/.config/
RUN wget https://raw.githubusercontent.com/Jonathan-Zollinger/PeanutButter-Unicorn/main/config-linux/starship.toml -O ~/.config/starship.toml


RUN echo "alias vi=vim"
RUN echo "set -g default-terminal "screen-257color"" >> ~/.tmux.conf
RUN echo 'eval "$(starship init bash)"' | tee -a  ~/.bashrc
RUN echo "alias ls='ls --color'" | tee -a ~/.bashrc

CMD ["/bin/bash"] 
