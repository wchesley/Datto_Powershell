##################### Create_svcNessus_User #########################
# Describe script here: Creates svcNessus user if it doesn't 
# already exist, does nothing if user exists. 
# takes password as variable from Datto or env. 

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/22/2023 - Created Script                                       #
# 08/24/2023 - make svcNessus admin user, enable admin shares, 
# and allow File and Print (SMB) through inbound firewall.

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

$op = Get-LocalUser | where-Object Name -eq "svcNessus" | Measure

if ($op.Count -eq 0) {
    $passwd = ConvertTo-SecureString $env:password -AsPlainText -Force
    New-LocalUser -Name "svcNessus" -Description "Nessus service account" -Password $passwd
    Datto_Output("Created svcNessus user")
}
else {
    Datto_Output("svcNessus user already exists")
}

# add svcNessus to local admin group: 
Add-LocalGroupMember -Group Administrators -Member svcNessus -Verbose

# Enable admin shares and allow access to them: 
Set-ItemProperty -Name AutoShareWks -Path HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -Value 1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "LocalAccountTokenFilterPolicy" /t REG_DWORD /d 1 /f

# Allow File and Print Sharing: 
Enable-NetFirewallRule -Name FPS-SMB-In-TCP