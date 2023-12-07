######################## Script_Template ############################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Your_Name                                                 #
# Change List: List your changes here:                              #
# 04/26/2023 - Created Script                                       #
# 08/08/2023 - added redirection for Write-Host variable            #
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

wget "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/en-US/17.10.4.1/x64/msodbcsql.msi" --Outfile "msodbcsql.msi"
msiexec.exe msodbcsql.msi /passive
$odbcDrivers = Get-OdbcDriver | Where-Object { $_.Name -Like '*ODBC*' } | Sort-Object Name, Platform | Select-Object @{name='Driver'; expression={$_.Name + ' (' + $_.Platform + ')'}}
Datto_Output("Installation started in passive mode. ODBC Drivers on machine are `n$odbcDrivers")