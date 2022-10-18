# try {
#     $ErrorActionPreference = 'Silently-Continue'
#     Remove-Module PeanutbutterUnicorn
# }catch {
#     Write-Verbose "ignoring failure of 'Remove-Module Peanutbutterunicorn"
# }
# $ErrorActionPreference = 'Continue'
# $env:PSModulePath = "$(Split-Path $PWD -Parent);$($env:PSModulePath)"
# RefreshEnv
using module "../PeanutbutterUnicorn.psm1"

Describe 'Join-Vlab' {

    Context 'Authenticating with vlab' {

        BeforeEach {
            Write-Verbose "looking for available *.cred file in $($PWD)..."
            if ( -not ( Get-ChildItem -Recurse "*.cred" | Test-Path -PathType Leaf ) ) {
                Get-Credential -Message "please enter valid credentials to use in tests:" |
                Export-Clixml -Path ".\TestResources\$($_.UserName).cred"
            }
            $tempCredentials = (Get-ChildItem -Recurse "*.cred")[0]
            Write-Verbose "Using $($tempCredentials) for this test's credentials."

            @{'ViServerAddress'           = 'vlabw1vc.nqeng.lab'
                'VlabCredentialsFilePath' = $tempCredentials 
            }.GetEnumerator() | ForEach-Object { 
                Set-Variable -Name $_.Key -Value $_.Value -Scope global -Visibility Public
            }
        }


        it 'Connects to the vlab server with global variables' {
            Write-Debug ([string]::Format("Available Variables: `n`t{0}`n`t{1}", 
                "VlabCredentialsFilePath: '$($VlabCredentialsFilePath)'",
                "ViServerAddress: '$($ViServerAddress)'"))
            Join-Vlab
            $global:DefaultVIServer.Name | Should -Be $ViServerAddress
        }
    }
}
