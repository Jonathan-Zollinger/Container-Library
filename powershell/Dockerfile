FROM vmware/powerclicore:latest

LABEL author = "Jonathan Zollinger"

VOLUME ["peanutbutter"]

WORKDIR /peanutbutter

COPY . ./

RUN pwsh -c Import-Module ./PeanutbutterUnicorn.psd1 

CMD [ "/bin/pwsh" ]
