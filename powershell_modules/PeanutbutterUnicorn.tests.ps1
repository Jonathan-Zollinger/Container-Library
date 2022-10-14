Import-Module .\PeanutbutterUnicorn.psm1
$DebugPreference = 'Continue'

Describe 'Join-Vlab' {

    BeforeEach {
        RefreshEnv
        Import-Module .\PeanutbutterUnicorn.psm1
    }

    Context 'When Credentils are available from file'{
        BeforeEach {
            if ( -not ( Test-Path -PathType Leaf ".\TestResources\*.cred" ) ){
                Get-Credential -Message "please enter valid credentials to use in tests:" | `
                ForEach-Object { Export-Clixml -InputObject $_ -Path ".\TestResources\$($_.UserName).cred" }
            }
            $Variables = @{
                'ViServerAddress'         = 'vlabw1vc.nqeng.lab'
                "VlabCredentialsFilePath" = "$($(Get-ChildItem -Recurse *.cred).DirectoryName)\$($(Get-ChildItem -Recurse *.cred).PSChildName)"
            }
            foreach ($Variable in $Variables.Keys) {
                Set-Variable -Scope Global -Name $Variable -Value $Variables[$Variable]
                Write-Debug "set `$$($Variable)=$($Variables[$Variable]) as a global variable"
                #TODO(Jonathan) Add debug output to Join-Vlab
            }
            Remove-Variable -Name Variable, Variables # removes the literal vars "$Variable" and "$Variables"
        }
        it 'Connects to the vlab server' {
            Join-Vlab
            $global:DefaultVIServer.Name | Should be $ViServerAddress
        }
    }
}