########################### IEActiveX ###############################
# Description: Disable or Enable IEActiveX controls via GUID.       #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 12/11/2023 - Adapted script from: 
# https://mickitblog.blogspot.com/2014/05/powershell-enable-or-disable-internet.html 
# https://github.com/MicksITBlogs/PowerShell/blob/baf3f80e40039706e1f1da7789600af56b5c3010/IEActiveX.ps1

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

# Env Variable changes: 
$ErrorView = 'NormalView'
$ErrorActionPreference = 'Stop'

# Begin IEActiveX
# Script is adapted from: https://mickitblog.blogspot.com/2014/05/powershell-enable-or-disable-internet.html 
# https://github.com/MicksITBlogs/PowerShell/blob/baf3f80e40039706e1f1da7789600af56b5c3010/IEActiveX.ps1
<#
.SYNOPSIS
   Enable/Disable IE Active X Components
.DESCRIPTION
   
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   EnableIEActiveXControl "Application Name" "GUID" "Value"
   EnableIEActiveXControl "Flash for IE" "{D27CDB6E-AE6D-11CF-96B8-444553540000}" "0x00000000"
#>

#Declare Global Memory
Set-Variable -Name Errors -Value $null -Scope Global -Force
Set-Variable -Name LogFile -Value "c:\Temp\IeActiveXLogs\IEActiveX.log" -Scope Global -Force
Set-Variable -Name RelativePath -Scope Global -Force

Function GetRelativePath { 
	$Global:RelativePath = (split-path $SCRIPT:MyInvocation.MyCommand.Path -parent)+"\" 
}

Function DisableIEActiveXControl ($AppName,$GUID,$Flag) {
	$Key = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\ActiveX Compatibility\"+$GUID
	If ((Test-Path $Key) -eq $true) {
		Write-Host $AppName"....." -NoNewline
		Set-ItemProperty -Path $Key -Name "Compatibility Flags" -Value $Flag -Force
		$Var = Get-ItemProperty -Path $Key -Name "Compatibility Flags"
		If ($Var."Compatibility Flags" -eq 1024) {
			Write-Host "Disabled" -ForegroundColor Yellow
		} else {
			Write-Host "Enabled" -ForegroundColor Red
		}
	}
}

Function EnableIEActiveXControl ($AppName,$GUID,$Flag) {
	$Key = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\ActiveX Compatibility\"+$GUID
	If ((Test-Path $Key) -eq $true) {
		Write-Host $AppName"....." -NoNewline
		Set-ItemProperty -Path $Key -Name "Compatibility Flags" -Value $Flag -Force
		$Var = Get-ItemProperty -Path $Key -Name "Compatibility Flags"
		If ($Var."Compatibility Flags" -eq 0) {
			Write-Host "Enabled" -ForegroundColor Yellow
		} else {
			Write-Host "Disabled" -ForegroundColor Red
		}
	}
}

# Example usage: 
#DisableIEActiveXControl "Flash for IE" "{D27CDB6E-AE6D-11CF-96B8-444553540000}" "0x00000400"
#EnableIEActiveXControl "Flash for IE" "{D27CDB6E-AE6D-11CF-96B8-444553540000}" "0x00000000"

# DisableIEActiveXControl "Autodesk IDrop Heap Corruption" "{21E0CB95-1198-4945-A3D2-4BF804295F78}" "0x00000400"
# Keyworks: 
# {B7ECFD41-BE62-11D2-B9A8-00104B138C8C} - C:\Program Files (x86)\Pervasive Software\PSQL\bin\keyhelp.ocx
# {45E66957-2932-432A-A156-31503DF0A681} - C:\Program Files (x86)\Pervasive Software\PSQL\bin\keyhelp.ocx
# {1E57C6C4-B069-11D3-8D43-00104B138C8C} - C:\Program Files (x86)\Pervasive Software\PSQL\bin\keyhelp.ocx

DisableIEActiveXControl "$env:ControlName" "$env:ControlUID" "0x00000400"
# SIG # Begin signature block
# MIIItQYJKoZIhvcNAQcCoIIIpjCCCKICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCztii9Xqw304ND
# G7DdYH1V4FFqYrZBWKMS1QT9BiXw3aCCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
# 3GTajaaOAAAAAAAWMA0GCSqGSIb3DQEBCwUAMFQxFTATBgoJkiaJk/IsZAEZFgVs
# b2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMUd2Vz
# dGdhdGVjb21wLURDMDEtQ0EwHhcNMjQwOTE4MjAzMzMxWhcNMjUwMTEzMTk1NDQ2
# WjAZMRcwFQYDVQQDEw5XYWxrZXIgQ2hlc2xleTCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBALdQvSsBcZJrgzxqe048NIx6FztzFNcu8CbziEvfMjNSnzVY
# FpQ4SqZV955ub+/6QnkNrhHY+pQlPeajpcOvgCysdGBSe26+8MpC8xGjzLU5MeOT
# cPTZAs/oSo1J9vAo94zUHguV/t0f7KlBhFmnFrkCrOA3nwsh2VFWD+OZYKKyv7tP
# uAzwVFNROKCJt+wpC+OK3akgr8bMM/S/gEl4hGkV2exHv3hdZZPUbchRhwvtH2Ax
# 3YC1EAqxPGns5uM98qqYpU9fe/BLoYFESu1Sno9/p0c9cwLqXQcs9aVrUm8AZgsR
# ed+zdAcMlbLWWBshK47L/bnPx50OILB7NvlPjpUCAwEAAaOCAvcwggLzMDwGCSsG
# AQQBgjcVBwQvMC0GJSsGAQQBgjcVCIWPl3mFh8xJg/mNCd2UeoepixJIhp2sbIS1
# w3sCAWQCAQIwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsG
# CSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFHP608OuQEkxYq3u
# zEw2N/A53E3VMB8GA1UdIwQYMBaAFGDzwfRAj9EqefCsmrUwHE3f1WieMIHaBgNV
# HR8EgdIwgc8wgcyggcmggcaGgcNsZGFwOi8vL0NOPXdlc3RnYXRlY29tcC1EQzAx
# LUNBLENOPVdHQy1EQzAxLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNl
# cyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPXdlc3RnYXRlY29tcCxE
# Qz1sb2NhbD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xh
# c3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwgc0GCCsGAQUFBwEBBIHAMIG9MIG6Bggr
# BgEFBQcwAoaBrWxkYXA6Ly8vQ049d2VzdGdhdGVjb21wLURDMDEtQ0EsQ049QUlB
# LENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZp
# Z3VyYXRpb24sREM9d2VzdGdhdGVjb21wLERDPWxvY2FsP2NBQ2VydGlmaWNhdGU/
# YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MDYGA1UdEQQv
# MC2gKwYKKwYBBAGCNxQCA6AdDBt3Y2hlc2xleUB3ZXN0Z2F0ZWNvbXAubG9jYWww
# TAYJKwYBBAGCNxkCBD8wPaA7BgorBgEEAYI3GQIBoC0EK1MtMS01LTIxLTg5MzYx
# OTIyNS05ODMxNjM4NDUtNzM0MzcyNDA1LTI2MzMwDQYJKoZIhvcNAQELBQADggEB
# ACTp/R8QXQAHRY7b4gV/4RNUfCWBBj5CAsqZXy8pGGpFiAX6inB64CBhqbKD7djv
# elBUCtmBICHbQ5gj/gHKdeIs2Pe6TxJMUbz3D9cNCVZ/bZFLxUZ1zWr/VwNsUXEL
# zqGLwX7Cy/OJaUmQDFSJGfXLbdfyKywa3qgl8j5YOjXItOcf86d9HiN9eDJfW077
# YsYiNeWsg4IAVRpjuDvzGPu+ropqCtJuNLk7cKHQjTU4RTCUzifJON8z7uFU+Hl0
# QutmghDCjojqvWsoAOUIaF4EQ+ZnuTaFuL5bQX4M4bHk6QI/xE4o5RkBPoeNuNE7
# NE1hS/lI3CECKUoA5598UusxggIUMIICEAIBATBrMFQxFTATBgoJkiaJk/IsZAEZ
# FgVsb2NhbDEcMBoGCgmSJomT8ixkARkWDHdlc3RnYXRlY29tcDEdMBsGA1UEAxMU
# d2VzdGdhdGVjb21wLURDMDEtQ0ECEyAAAAAWZC7cZNqNpo4AAAAAABYwDQYJYIZI
# AWUDBAIBBQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0B
# CQQxIgQgF1a1pvRhyYtUJ7n4kf6uydmLE108Rw3y5bvX0dKFcU4wDQYJKoZIhvcN
# AQEBBQAEggEAcg3FovMO5I4ucanlyd7XefuuyioL6QW0wldHoyfmD9hLfLtTtiIb
# tbOgzTN6vKCxnKU3B8t+G/o+ypDPr1qWUGXZzX8hKQUcjwEmk03fifi1QJPfCcFZ
# ik/E1o2jhSNl7QktexhcsHrPOiyte/KPfpn7FOzllQ8ICwCCJfyQmwLPkSncj5ko
# badlsUQBjQTP7tvj+bdZIKpVZ3DashaNB8jNNnM7dzxeSier5aR0PWPc6mKRzMZP
# y/YG8abX/BGEpUv+vaUg7avHh2vfdx2mIWcV8yj9FcbFWQ20zgMjOwSbdQIo7s4t
# VD3+BBfj2wqT+jpFCOMOO1wMYWUOEJDgWg==
# SIG # End signature block
