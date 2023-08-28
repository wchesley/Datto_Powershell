##################### Intel_AMT_Remediation #########################
# Description: Installs the attached 'intel-sa-0075 detection and   #
# mitigation.msi' and then uses this tool to detect and remediate   #
# Intel Management Engine vulnerabilities from Nessus.              #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/28/2023 - Created Script                                       #

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

# Install Detection and Mitigation tool: 
msiexec.exe /i Intel-SA-00075 Detection and Mitigation Tool.msi /qn

# Wait a minute for tool to install: 
Start-Sleep -s 60


# Use the tool to detect vulnerability: 
"C:\Program Files (x86)\Intel\Intel-SA-00075 Detection and Mitigation Tool\Intel-SA-00075-console.exe" | Invoke-Expression

# Now use the tool to remediat the vulnerability: 
"C:\Program Files (x86)\Intel\Intel-SA-00075 Detection and Mitigation Tool\Intel-SA-00075-console.exe -u" | Invoke-Expression