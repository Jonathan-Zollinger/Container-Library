function Connect-Vlab {
    <#
    .SYNOPSIS
    Establishes  connection to the provo vlab vsphere server system

    .DESCRIPTION
    This cmdlet establishes a connection to vlab server system in Provo, Utah. The cmdlet starts a new session or re-establishes a previous session with a vCenter Server system using the specified parameters.

    When you attempt to connect to a server, the server checks for credentials saved to the $VlabCredentialsFilePath. Otherwise a prompt will accept the username and password required to access the vlab, as you would through the browser.

    .INPUTS
    $VlabCredentialsFilePath is the credentials filepath to login to the vlab. This is to be a .cred filetype, which powershell can save with the Export-Clixml cmdlet. 


    .LINK
    http://developer.vmware.com/docs/powercli/latest/vmware.vimautomation.core/commands/connect-viserver
    
    .EXAMPLE
    $VlabCredentialsFilePath = $PWD\vlab.cred
    Get-Credential | Export-Clixml $VlabCredentialsFilePath
    Join-Vlab
    #>

}

New-Alias -Name "Punch-ItChewie" -Value Join-Vlab