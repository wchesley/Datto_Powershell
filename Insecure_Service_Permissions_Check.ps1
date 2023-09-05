############## Insecure_Service_Permissions_Check ###################
# Description: Use accesschk.exe to search for insecure windows     #
# service permissions. This script does nothing but list insecure   # 
# services.                                                         #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/25/2023 - Created Script                                       #

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

# Set our location to Temp directory
Set-Location "C:\Temp"

$downloadOrNot = Test-Path "C:\Temp\AccessChk"

if (-not($downloadOrNot))
{
    # Accesschk doesn't exist, download it: 
    Invoke-WebRequest -Uri "https://download.sysinternals.com/files/AccessChk.zip" -OutFile AccessChk.zip
    Expand-Archive "AccessChk.zip"
    Set-Location "C:\TempAccessChk"
}
else {
    # AccessChk exists, set our location there
    Set-Location "C:\Temp\AccessChk"
}

$AuthUsrs = ./accesschk.exe -uwcqv “Authenticated Users” *
$Everyone = ./accesschk.exe -uwcqv “Everyone” *

Datto_Output("Insecure services for Authorized Users:`n$AuthUsrs`n`nInsecure services for Everyone:`n$Everyone")