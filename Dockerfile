FROM alpine:3.13 AS builder

LABEL authors="Jonathan Zollinger"
LABEL description="neovim with local folder"

RUN apk update && apk add --no-cache wget net-tools 
