####################### Update_Windows_OS ###########################
# Describe script here: This script updates windows OS and does not #
# reboot the host.                                                  #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/11/2023 - Created Script                                       #

#####################################################################

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
    # General Variables for Datto: 
    $StartResult = Write-Host "<-Start Result->" 6>&1
    $EndResult = Write-Host "<-End Result->" 6>&1
    
    $StartResult
    Write-Host "$message"
    $EndResult
}

try 
{ 
# Check if NuGet is installed, if not, install it: 
    if(Get-PackageProvider | Where-Object {$_.Name -eq "Nuget"}) 
    { 
        "Nuget Module already exists" 
    } 

    else 
    { 
        "Installing nuget module" 
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force 
    } 
# Check if PSWindowsUpdate exists if not, add it
    if(Get-Module -ListAvailable | where-object {$_.Name -eq "PSWindowsUpdate"}) 
    { 
        "PSWindowsUpdate module already exists" 
    } 

    else 
    { 
        "Installing PSWindowsUpdate Module" 
        install-Module PSWindowsUpdate -Force 
    } 
# Update the OS
    Import-Module -Name PSWindowsUpdate 

    "Starting updation -->" + (Get-Date -Format "dddd MM/dd/yyyy HH:mm")  

    install-WindowsUpdate -AcceptAll -ForceDownload -ForceInstall -IgnoreReboot 

    "Updation completed -->"+ (Get-Date -Format "dddd MM/dd/yyyy HH:mm") 

} 

catch { 

    Datto_Output($_.Exception.Message) 

} 