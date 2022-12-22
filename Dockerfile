FROM anatolelucet/neovim:stable
RUN apk update && apk add --no-cache wget net-tools 
