FROM vmware/powerclicore:latest

LABEL author = "Jonathan Zollinger"

VOLUME ["peanutbutter"]

WORKDIR /peanutbutter

COPY powershell_modules/* ./

RUN pwsh -c Import-Module ./PeanutbutterUnicorn.psd1 

CMD [ "/bin/pwsh" ]
