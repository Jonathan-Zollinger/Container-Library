FROM redhat/ubi8:8.4

ARG PKG_DEPS="unzip git wget curl dirmngr gnupg2 binutils net-tools man ca-certificates"

RUN yum install -y ${PKG_DEPS} && yum update -y

ENV TERM="xterm-256color"
CMD "/bin/bash"
