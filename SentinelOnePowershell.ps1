######################## SentinelOnePowershell ######################
# Installer script for SentinelOne, to be used with Datto RMM.      #
# Script expects that SentinelOne installer is packaged with Datto  #
# Component. Requires SentinelOne token as S1SiteToken in Component #

#####################################################################
# Author: Billy Robbins, Brandon Terry, Walker Chesley              #
# Change List: List your changes here:                              #
# 04/01/2022 - Created Script                                       #
# 05/17/2023 - WC: Added script to template, changed install        #
# command to 'start-process' rather than & .\SentinelInstaller.exe  #
# added exit codes.                                                 #
#####################################################################

# General Variables for Datto: 
$StartResult = Write-Host "<-Start Result->"
$EndResult = Write-Host "<-End Result->"

# Wrapper function to output data into Datto

function Datto_Output {
    <#
        .SYNOPSIS
            Wrapper function to output data into Datto
        .EXAMPLE
            Datto_Output("The software was installed")
    #>
    param (
        # The text you want to output into Datto
        $message
    )
    $StartResult
    Write-Host "$message"
    $EndResult
}

$software = "Sentinel Agent"
$directory = "C:\Software"
$installed = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -contains $software }) -ne $null
$token = $env:S1SiteToken

If (-Not $installed) {
    New-Item -ItemType Directory -Force -Path $directory
    Datto_Output("'$software' was not found, attempting to install.")

    Start-Process SentinelInstaller.exe -ArgumentList "/SITE_TOKEN=$token /SILENT"
    If ($installed) {
        Write-output "'$software' is now installed."
        Exit 0;
    }
    else {
        Write-output "'$software' did not install correctly."
        Exit 1; 
    }
}
else {
    Write-output "'$software' was already installed."
    Exit 0;
}