################ Change_MSOffice_Update_Channel #####################
# Describe script here: List how to use the script, list input      #
# arguements, return values and exit codes                          #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 08/18/2023 - add Script to Datto                                  #

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

<#
##########################################################
#Script Description: it is used to change office 365 update channel
#Author: Selcuk ERGUL
#Date Created: 30/09/2021
#Version: V1.0 - First relase.
List of Office 365 Update Channels: 
Monthly   Enterprise Channel
CDNBaseUrl =   http://officecdn.microsoft.com/pr/55336b82-a18d-4dd6-b5f6-9e5095c314a6

Current   Channel 
CDNBaseUrl =   http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60

Current   Channel (Preview)
CDNBaseUrl =   http://officecdn.microsoft.com/pr/64256afe-f5d9-4f86-8936-8840a6a4f5be

Semi-Annual   Enterprise Channel
CDNBaseUrl =   http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114

Semi-Annual   Enterprise Channel (Preview)
CDNBaseUrl =   http://officecdn.microsoft.com/pr/b8f9b850-328d-4355-9145-c59439a0c4cf

Beta Channel
CDNBaseUrl =   http://officecdn.microsoft.com/pr/5440fd1f-7ecb-4221-8110-145efaa6372f
#>	

$UpdateChannel = "http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60"
$CTRPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
$CDNBaseUrl = Get-ItemProperty -Path $CTRPath -Name "CDNBaseUrl" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty "CDNBaseUrl"
if ($CDNBaseUrl -ne $null) {
    if ($CDNBaseUrl -notmatch $UpdateChannel) {
        # Set new update channel
        Set-ItemProperty -Path $CTRPath -Name "CDNBaseUrl" -Value $UpdateChannel -Force
		if($?){Datto_Output("CDNBaseUrl has been changed as Current Channel")}
		else {Datto_Output("CDNBaseUrl has not been changed as Current Channel")}
        # Trigger hardware inventory
        Invoke-WmiMethod -Namespace "root\ccm" -Class "SMS_Client" -Name "TriggerSchedule" -ArgumentList "{00000000-0000-0000-0000-000000000001}"
    }
	else
	{Datto_Output("update channel is already as Current Channel and CDNBaseUrl is $CDNBaseUrl")}
}
else
{Datto_Output("CND Base Url registery key does not exsist.")}
# SIG # Begin signature block
# MIIItQYJKoZIhvcNAQcCoIIIpjCCCKICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBTxfxIsC4crOCr
# ypIk8RIXS48rw0g35QODCkuzpsKLV6CCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# CQQxIgQgUv+je/ele4lpASbZ3j9VfyMB1wc2bYmPZYxNMokK020wDQYJKoZIhvcN
# AQEBBQAEggEAQR6hil05uu6rxMoZmRQOWiBnd/q/hdMnRqSQsQiic4x0QDdj+9X3
# MHrkpUOfniyNiKgaqaOavwL4+LommcBSGLn9kauF63vrNZE9EaDBw6jJgoelRKYW
# s9LBA5wuYwTp8I93ZmFredV/5Ue1mRlRT6XBDKAuVIsQQuKsXzBH12gMSw+mpkBy
# 2/H7/YnkFKXa5p8Js5Hk4FYte34AE8OJSktf45F09RbuzVlSgJe7CW5Z7hDt+eT/
# lXgUgnKY5k+jvVDUq/YcD/ipPLyxO6VFrjTGmrlKmjyv6lS/d7xTwP80e0DolT9H
# iDgfDbwaxJtZuIQItxhvPdKfO/DzTkla6g==
# SIG # End signature block
