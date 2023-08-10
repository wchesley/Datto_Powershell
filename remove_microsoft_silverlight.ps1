####################### remove_Silverlight ##########################
# Describe script here: This script removes microsoft silverlight 	#
# if it is installed on the system. NuGet will also get installed	#
# as Uninstall-Package requires it to function. 					#

#####################################################################
# Author: Walker Chesley											#
# Change List: List your changes here:                              #
# 08/10/2023 - Created Script                                       #

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

try {
	Install-PackageProvider -Name NuGet -Scope CurrentUser -Confirm -ErrorAction Stop
}
catch {
	Write-Error "Failed to install NuGet, this is required to remove silverlight."
}

try {
    $silverlight = Get-Package -Name "Microsoft Silverlight" | Uninstall-Package -ErrorAction Stop
}
catch {
    Write-Error "Failed to remove Microsoft Silverlight"
}
Datto_Output("Microsoft silverlight has been uninstalled.")