############################ mount_drive ############################
# Mounts remote drive to local file system                          #
# Takes $env:MountDrive (Network share path) and                    #
# $env:DriveLetter (Mounted drive letter) as arguements.            #
# if $env:DriveLetter isn't specified a random one is chosen        #
# If mount isn't available on system, falls back to New-PSDrive     #
# Exits 1 on error and 0 on success                                 #
#####################################################################
# Author: Walker Chesley                                            #
# Change List:                                                      #
# 04/26/2023 - Created Script                                       #
#                                                                   #
#####################################################################

# General Variables for Datto: 
$StartResult = Write-Host "<-Start Result->"
$EndResult = Write-Host "<-End Result->"

# Verify Datto env vars to mount drive are specified
# $env:MountDrive should be in the format: \\<computername>\<sharename>
if ($env:MountDrive -eq "") {
    $StartResult
    Write-Error "No Path Specified to Mount, path is set to: $env:MountDrive"
    $EndResult
    exit 1
}

# Check if drive letter is specified, if not, use first available letter
# $env:MountLetter
if ($env:MountLetter -eq "") {
    $env:MountLetter -eq "*"
}

# Check that we can use mount command and mount drive:
try {
    mount $env:MountDrive $env:MountLetter
    $StartResult
    Write-Host "Mouned $env:MountDrive to $env:MountLetter"
    $EndResult
    exit 0
}
# If mount is not available, fall back to New-PSDrive: 
catch [CommandNotFoundException] {
    $StartResult
    Write-Host "Mount command not found, falling back to New-PSDrive"
    $EndResult
    try {
        New-PSDrive -Name "$env:MountLetter" -Root "$env:MountDrive" -Persist -PSProvider 'FileSystem'
        $StartResult
        Write-Host "Mouned $env:MountDrive to $env:MountLetter"
        $EndResult
        exit 0
    }
    catch {
        $StartResult
        Write-Host "Failed to mount Drive `n$Error[0]"
        $EndResult
        exit 1
    }
}
catch {
    $StartResult
    Write-Host "Failed to mount Drive `n$Error[0]"
    $EndResult
    exit 1
}

# SIG # Begin signature block
# MIIItQYJKoZIhvcNAQcCoIIIpjCCCKICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBeMxq/yo0YW3HR
# OBxu+G31pxjZLsx+IJl3kzsn20KejqCCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# CQQxIgQgBmPSjyT2x6qnAS6EtsDfLf1hAjkOxvaQaJ2GBi8Xq68wDQYJKoZIhvcN
# AQEBBQAEggEASn17wi2didvIITcQMcavGEX19jHdnVRG09MnAzmee/ny2liORyq7
# PIFG+MxE1t9q7T7LwrqQGZZ6xaTzaLYxPMB3jBkE/xV3/lIe8ZRBvsghgSfTfRSn
# J6SXxLLKz4lDQr9umhfv+y3Y7AkApR2YdfsgMxFa6NuQ2t9dXkQ4jyAcQK5YwSBs
# Qya6dMX9SOEMTTWK2CIKMOhLsrHAvrxjZXqI6SGdyeIUrpW/aAdlxqnXmgAb/FBD
# 2kGoOCxJOCW/zOobNu+iRuV8QHIW36P1GXwhxakHiGFbYSRxNH9PpV/kjbR9I5lk
# +pWZKeDcQrV10JBQXUwLSX6uoQC9/FgpnQ==
# SIG # End signature block
