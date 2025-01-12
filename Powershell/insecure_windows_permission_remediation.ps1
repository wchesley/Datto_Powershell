################### Secure-WindowsServices.ps1 ######################
# Description: Iterates through windows services and secures        #
# any insecure permissions on the host. Optional arguements are     #
# -LogOutput which places logs at                                   #
# C:\<PC-Hostname>_SecureWindowsServices.txt                        #
# USE WITH CAUTION! Some services might still be in use and depend
# on the permissions you are about to remove. 

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 04/26/2023 - Created Script                                       #
# 08/08/2023 - added redirection for Write-Host variable            #
# 08/10/2023 - Script pulled from: https://github.com/astrixsystems/Secure-WindowsServices/blob/master/Secure-WindowsServices%20v1.8.ps1

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
.SYNOPSIS
	Name: Secure-WindowsServices.ps1
	Description: The purpose of this script is to secure any Windows services with insecure permissions.

.NOTES
	Author:					Ben Hooper at Astrix
	Tested on:				Windows 7 Professional 64-bit, Windows 10 Pro 64-bit
	Version:				1.8
	Changes in v1.8 (2020/03/06 14:08):	Added handling for Windows services where the paths don't actually exist.
	Changes in v1.7 (2019/11/21 10:14):	Corrected "Windows service secured" logic so that it'll only report if it was actually successful in securing it.
	Changes in v1.6 (2019/11/20 14:31):	Fixed compatibility with Windows 7 / PowerShell < 3.0.
	Changes in v1.5 (2019/11/20 13:43):	Added special handling for Windows services located in "C:\Windows\system32\" so that the permissions are reduced to read & execute instead of being removed.
	Changes in v1.4 (2019/11/20 12:33):	Added post-run report of which, if any, services were secured.
	Changes in v1.3 (2019/11/20 11:39):	Updated to bring in line with enhancements of Update-hMailServerCertificate v1.13 (write access check to log file, auto-elevate, coloured statuses, etc) and changed tags to Info, Unknown, Pass, FAIL, Success, and ERROR.
	Changes in v1.2 (2018/10/15):		Enhanced output by (1) changing output type from "check performed-action result" with just "action result" which makes it easier to read with less indentations, (2) adding tags ("[FAILED]", "[SUCCESS]", and "[NOTIFICATION]") for quick checking of results, and (3) tweaking logging behaviour.
	Changes in v1.1 (2018/10/05):		Added handling of inherited permissions.
	
.PARAMETER LogOutput
	Logs the output to the default file path "C:\<hostname>_Secure-WindowsServices.txt".
	
.PARAMETER LogFile
	When used in combination with -LogOutput, logs the output to the custom specified file path.

.EXAMPLE
	Run with the default settings:
		Secure-WindowsServices
		
.EXAMPLE 
	Run with the default settings AND logging to the default path:
		Secure-WindowsServices -LogOutput
	
.EXAMPLE 
	Run with the default settings AND logging to a custom local path:
		Secure-WindowsServices -LogOutput -LogPath "C:\$env:computername_Secure-WindowsServices.txt"
	
.EXAMPLE 
	Run with the default settings AND logging to a custom network path:
		Secure-WindowsServices -LogOutput -LogPath "\\servername\filesharename\$env:computername_Secure-WindowsServices.txt"
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

Param(
	[switch]$LogOutput,
	[string]$LogPath
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$RunAsAdministrator = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);

$global:FirstRun = $null;
$global:Script_PS1File_Name = Split-Path $MyInvocation.MyCommand.Path -Leaf;
$global:Script_PS1File_FullPath = $MyInvocation.MyCommand.Path;
[System.Collections.ArrayList]$global:InsecureWindowsServices = @();
[System.Collections.ArrayList]$global:SecuredWindowsServices = @();

$LogPath_Default = "C:\$env:computername`_$global:Script_PS1File_Name.log";

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Secure-WindowsServices {
	Param()
	
	Begin {
		Write-Host "Securing all Windows services...";
	}
	
	Process {
		Try {
			If ($FirstRun -Eq $Null){
				$FirstRun = $False;
			} Else {
				$FirstRun = $True;
			}
			
			If ($FirstRun -Eq $False){
				[System.Collections.ArrayList]$FilesChecked = @(); # This is critical to ensuring that the array isn't a fixed size so that items can be added;
				[System.Collections.ArrayList]$FoldersChecked = @(); # This is critical to ensuring that the array isn't a fixed size so that items can be added;
			}
			
			$WindowsServices = Get-WmiObject Win32_Service -ErrorAction Stop | Select Name, DisplayName, PathName | Sort-Object DisplayName;
			
			If (-Not ($WindowsServices)) {
				Write-Host -ForegroundColor Red "`t[ERROR] Could not find any Windows services. Exiting...";
				
				Break;
			}
			
			$WindowsServices_Total = $WindowsServices.Length;
			
			For ($i = 0; $i -LT $WindowsServices_Total; $i++) {
				$Count = $i + 1;
				
				$WindowsService_DisplayName = $WindowsServices[$i].DisplayName;
				$WindowsService_Path = $WindowsServices[$i].PathName;
				$WindowsService_File_Path = ($WindowsService_Path -Replace '(.+exe).*', '$1').Trim('"');
				$WindowsService_Folder_Path = Split-Path -Parent $WindowsService_File_Path;
				
				Write-Host "`tWindows service ""$WindowsService_DisplayName"" ($Count of $WindowsServices_Total)...";
				
				If ($FoldersChecked -Contains $WindowsService_Folder_Path){
					Write-Host -ForegroundColor Green "`t`t[Pass] Folder ""$WindowsService_Folder_Path"": Security has already been ensured.";
				} Else {
					$FoldersChecked += $WindowsService_Folder_Path;
					
					If (Test-Path $WindowsService_Folder_Path) {
						Write-Host -ForegroundColor Yellow "`t`t[Unknown] Folder ""$WindowsService_Folder_Path"": Security has not yet been ensured...";
						
						Ensure-InsecurePermissions -Path $WindowsService_Folder_Path -WindowsService $WindowsService_DisplayName;
					} Else {
						Write-Host -ForegroundColor Green "`t`t[Pass] Folder ""$WindowsService_Folder_Path"": Ignoring as doesn't actually exist.";
					}
				}
				
				If ($FilesChecked -Contains $WindowsService_File_Path){
					Write-Host -ForegroundColor Green "`t`t[Pass] File ""$WindowsService_File_Path"": Security has already been ensured.";
				} Else {
					$FilesChecked += $WindowsService_File_Path;
					
					If (Test-Path $WindowsService_File_Path) {
						Write-Host -ForegroundColor Yellow "`t`t[Unknown] File ""$WindowsService_File_Path"": Security has not yet been ensured...";
						
						Ensure-InsecurePermissions -Path $WindowsService_File_Path -WindowsService $WindowsService_DisplayName;
					} Else {
						Write-Host -ForegroundColor Green "`t`t[Pass] File ""$WindowsService_File_Path"": Ignoring as doesn't actually exist.";
					}
				}
				
				Write-Host "";
			}
		}
		
		Catch {
			Write-Host -ForegroundColor Red "[ERROR] Could not secure all Windows services.";
			$_.Exception.Message;
			$_.Exception.ItemName;
			Break;
		}
	}
	
	End {
		If($?){
			$SecuredWindowsServices_Total = $global:SecuredWindowsServices.Count;
			$InsecureWindowsServices_Total = $global:InsecureWindowsServices.Count;
			
			If ($SecuredWindowsServices_Total -Eq $InsecureWindowsServices_Total){
				If ($SecuredWindowsServices_Total -Eq 0){
					Write-Host -ForegroundColor Green "[Pass] All Windows services were already secure.";
				} Else {
					If ($SecuredWindowsServices_Total -Eq 1){
						Write-Host -ForegroundColor Green "[Success] The sole insecure Windows service was secured:";
					} Else {
						Write-Host -ForegroundColor Green "[Success] All $SecuredWindowsServices_Total insecure Windows services were secured:";
					}
					
					For ($i = 0; $i -LT $SecuredWindowsServices_Total; $i++) {
						$Count = $i + 1;
						
						$SecuredWindowsServices_DisplayName = $global:SecuredWindowsServices[$i];
						
						Write-Host "`t$Count. ""$SecuredWindowsServices_DisplayName""";
					}
				}
			} Else {
				Write-Host -ForegroundColor Red "[ERROR] Not all Windows services could be secured. Please review the log.";
			}
		}
	}
}

Function Ensure-InsecurePermissions {
	Param(
		[Parameter(Mandatory=$true)][String]$Path,
		[Parameter(Mandatory=$true)][String]$WindowsService
	)
	
	Begin {
		
	}
	
	Process {
		Try {
			$ACL = Get-ACL $Path;
			$ACL_Access = $ACL | Select -Expand Access;
			
			$InsecurePermissionsFound = $False;
			
			ForEach ($ACE_Current in $ACL_Access) {
				$SecurityPrincipal = $ACE_Current.IdentityReference;
				$Permissions = $ACE_Current.FileSystemRights.ToString() -Split ", ";
				$Inheritance = $ACE_Current.IsInherited;
				
				ForEach ($Permission in $Permissions){
					If ((($Permission -Eq "FullControl") -Or ($Permission -Eq "Modify") -Or ($Permission -Eq "Write")) -And (($SecurityPrincipal -Eq "Everyone") -Or ($SecurityPrincipal -Eq "NT AUTHORITY\Authenticated Users") -Or ($SecurityPrincipal -Eq "BUILTIN\Users") -Or ($SecurityPrincipal -Eq "$Env:USERDOMAIN\Domain Users"))) {
						$InsecurePermissionsFound = $True;
						$WindowsServiceSecured = $False;
						
						$global:InsecureWindowsServices += $WindowsService;
						
						Write-Host -ForegroundColor Yellow "`t`t`t[WARNING] Insecure Access Control Entry (ACE) found: ""$Permission"" granted to ""$SecurityPrincipal"".";
						
						If ($Inheritance -Eq $True){
							$Error.Clear();
							Try {
								$ACL.SetAccessRuleProtection($True,$True);
								Set-Acl -Path $Path -AclObject $ACL;
							} Catch {
								Write-Host -ForegroundColor Red "`t`t`t`t[FAIL] Could not convert Access Control List (ACL) from inherited to explicit.";
							}
							If (!$error){
								Write-Host -ForegroundColor Green "`t`t`t`t[Success] Converted Access Control List (ACL) from inherited to explicit.";
							}
							
							# Once permission inheritance has been disabled, the permissions need to be re-acquired in order to remove ACEs
							$ACL = Get-ACL $Path;
						}
						
						$Error.Clear();
						If ((($Path -Eq "C:\Windows\system32\svchost.exe") -Or ($Path -Eq "C:\Windows\system32")) -And ($SecurityPrincipal -Eq "BUILTIN\Users")) {
							Write-Host "`t`t`t`t[Info] Windows service is a default located in a system location so Access Control Entry (ACE) for ""BUILTIN\Users"" should be read & execute.";
							Try {
								$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($SecurityPrincipal, "ReadAndExecute", , , "Allow");
								$ACL.SetAccessRule($ACE);
								Set-Acl -Path $Path -AclObject $ACL;
							} Catch {
								Write-Host -ForegroundColor Red "`t`t`t`t[FAIL] Insecure Access Control Entry (ACE) could not be corrected.";
							}
							If (!$error){
								$WindowsServiceSecured = $True;
								Write-Host -ForegroundColor Green "`t`t`t`t[Pass] Corrected insecure Access Control Entry (ACE).";
							}
						} Else {
							Try {
								$ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($SecurityPrincipal, $Permission, , , "Allow");
								$ACL.RemoveAccessRuleAll($ACE);
								Set-Acl -Path $Path -AclObject $ACL;
							} Catch {
								Write-Host -ForegroundColor Red "`t`t`t`t[FAIL] Insecure Access Control Entry (ACE) could not be removed.";
							}
							If (!$error){
								$WindowsServiceSecured = $True;
								Write-Host -ForegroundColor Green "`t`t`t`t[Pass] Removed insecure Access Control Entry (ACE).";
							}
						}
						
						If (($WindowsServiceSecured -Eq $True) -And (-Not ($global:SecuredWindowsServices -Contains $WindowsService))){
							$global:SecuredWindowsServices += $WindowsService;
						}						
					}
				}
			}
			
			If ($InsecurePermissionsFound -Eq $False) {
				Write-Host -ForegroundColor Green "`t`t`t[Pass] No insecure Access Control Entries (ACEs) found.";
			}
		}
		
		Catch {
			Write-Host -ForegroundColor Red "`t`t`t[ERROR] Could not ensure security of Windows service.";
			$_.Exception.Message;
			$_.Exception.ItemName;
			Break;
		}
	}
	
	End {
		If($?){
			
		}
	}
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

If (-Not $LogPath) {
	$LogPath = $LogPath_Default;
}

# Check write access to log file
If ($LogOutput -Eq $True) {
	Try {
		[io.file]::OpenWrite($LogPath).Close();
	}
	Catch {
		Write-Host -ForegroundColor Red "[ERROR] Unable to log output to file '$LogPath' due to insufficient permissions.";
		Write-Host "";
		
		$LogOutput = $False;
	}
}

# Set up logging
If ($LogOutput -Eq $True) {
	Start-Transcript -Path $LogPath -Append | Out-Null;
	
	Write-Host "Logging output to file.";
	Write-Host "Path: '$LogPath'" 
	
	Write-Host "";
	Write-Host "----------------------------------------------------------------";
	Write-Host "";
}

# Handle admin
If ($RunAsAdministrator -Eq $False) {
	Write-Host "This script requires administrative permissions but was not run as administrator. Elevate now? (y/n)";
	$Elevate = Read-Host "[Input]";

	If (($Elevate -Like "y") -Or ($Elevate -Like "yes")){
		Write-Host "'Yes' selected. Launching a new session in a new window and ending this session...";
		
		# Preserve original parameters
		$AllParameters_String = "";
		ForEach ($Parameter in $PsBoundParameters.GetEnumerator()){
			$Parameter_Key = $Parameter.Key;
			$Parameter_Value = $Parameter.Value;
			$Parameter_Value_Type = $Parameter_Value.GetType().Name;
			
			If ($Parameter_Value_Type -Eq "SwitchParameter"){
				$AllParameters_String += " -$Parameter_Key";
				
			} ElseIf ($Parameter_Value_Type -Eq "String") {
				$AllParameters_String += ' -' + $Parameter_Key + ' "' + $Parameter_Value + '"';
			} Else {
				$AllParameters_String += " -$Parameter_Key $Parameter_Value";
			}
		}
		
		$Arguments = ' -NoExit -File "' + $global:Script_PS1File_FullPath + '"' + $AllParameters_String;
		
		If ($LogOutput -Eq $True) {
			Stop-Transcript | Out-Null;
		}
		
		Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $Arguments;
		
		# Stop-Process -Id $PID;
		
		Break;
	} Else {
		Write-Host "'No' selected. Exiting...";
		
		If ($LogOutput -Eq $True) {
			Stop-Transcript | Out-Null;
		}
		
		Break;
	}
} Else {
	Secure-WindowsServices;
}

Write-Host "";
Write-Host "----------------------------------------------------------------";
Write-Host "";

Write-Host "Script complete.";

If ($LogOutput -Eq $True) {
	Stop-Transcript | Out-Null;
}
# SIG # Begin signature block
# MIIItQYJKoZIhvcNAQcCoIIIpjCCCKICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBwev5TyNFiEJOr
# rXYWCqdjs7MTweMAHFGRGjJMgu+DkKCCBfcwggXzMIIE26ADAgECAhMgAAAAFmQu
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
# CQQxIgQgziekKUsDen2hyR3gxv0JjcZgu8C5Xhdp7TC0itRz514wDQYJKoZIhvcN
# AQEBBQAEggEAG2D1qDGUs1asm+l/ycF48pqs4lg78SnEFdHaKm1A3rXp5CyvXW+Q
# 4woq7BVM12ZoNofrfzod9A0wl3q2pXyAMzX/lji8XtBsIZxsmJZKXWuEKRGWmz0H
# NJdhOZZ/IrO5XXaPrK58jwCIk8Ij1CgJbBNMyg0hXQGuSkFVP21IHt6WAJXizcBJ
# /GPMMpeI+J/0eb5/473QPUJtxZjYgaZcsR9eyElISw6jGMImXiko+Luj8Adil/EC
# V+/vNBRiq0+iBagsSR5DNodrBYclZqXV7EMD3fbKevagyNn0uIr2ieuY3pkiciPt
# y+EUvdFjWyJFr8/F+ij54wFK7radh+E+7w==
# SIG # End signature block
