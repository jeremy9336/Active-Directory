<#
.SYNOPSIS
Get group membership from admin accounts

.DESCRIPTION
This PowerShell script will query AD and get group membership for admin accounts

.INPUTS
NONE

.OUTPUTS
c:\tmp\users\ users.txt & ~username~.txt

.EXAMPLE
.\Get_AD_Admin_Membership.ps1
Execute script from a PowerShell command line(Run as administrator)

.NOTES
Author:  Jeremy Rousseau

Version: 1.1
Date: 06/06/2018

Change Log
Version 1.0 Initial release
Version 1.1
-Updated to output to single file
-Correct time calculation
-Digitally signed script

.LINK
None
#>

#Display script begging time
[string]$BeginTime = Get-Date -format HH:mm:ss
Write-Host -ForegroundColor Green "Beginning script at $BeginTime"

# Load AD Module for PowerShell
Import-Module ActiveDirectory

# Create some variables
#Path
[string]$Path = "C:\tmp\admin_accts"
#Files
[string]$Admins_File = "admins.txt"
[string]$All_Admins_File = "All_Admins.txt"
#Full Paths
[string]$Admins_Path = $Path+'\'+$Admins_File
[string]$All_Admins_Path = $Path+'\'+$All_Admins_File

#Test for output path, create if not present
$PathExists = Test-Path $Path #test
if ($PathExists -eq $True) { #If true do nothing
    }
    else { #Else create path
    (New-Item $Path -type directory), (Write-Host -ForegroundColor Green "Creating output directory: $Path")
    }

#Test for output file, remove if present
$Admins_FileExists = Test-Path $Admins_Path #test
if ($Admins_FileExists -eq $True) {  #If true remove file
    (Remove-Item $Admins_Path), (Write-Host -ForegroundColor Yellow "Output file pre-exsisted, deleted")
    }
    else { #Else do nothing
    }

#Get admin accounts from AD, select account name, sort, format output
Get-ADUser -filter '*' -SearchBase "OU=Admins,OU=???,DC=abc,DC=net" | Select-Object SamAccountName | `
	Sort-Object -property SamAccountName | Format-Table -AutoSize -Wrap -HideTableHeaders | `
	Out-String -Stream | where {$_} | foreach { $_.TrimEnd()} | out-file -filepath $Admins_Path

#Measure and display number of admin accounts
$Measure = Get-Content $Admins_Path | Measure-Object
$CountAdmins = $Measure.Count
Write-Host -ForegroundColor Green "$CountAdmins admin accounts"

# Get user group information
Write-Host -ForegroundColor Green "Querying each admin account..."
$username = Get-Content $Admins_Path
$username = $username.TrimEnd()
ForEach ($i in $username) { 
	(Write-Host -ForegroundColor Green "$i"),(echo $i":" | out-file -filepath $All_Admins_Path -append),(Get-ADPrincipalGroupMembership $i | `
	Select-Object name | sort -property name | format-table @{Label="Groups";Expression={($_.name)}} -autoSize | `
	out-file -filepath $All_Admins_Path -append),(echo ========== | out-file -filepath $All_Admins_Path -append)
	}
Write-Host -ForegroundColor Green "Output written to $Path"

#Calculate and display how long it took script to complete
[string]$EndTime = Get-Date -format HH:mm:ss
Write-Host -ForegroundColor Green "Script Completed at $EndTime"
[string]$TimeDiff = New-TimeSpan -Start $BeginTime -End $EndTime
Write-Host -ForegroundColor Green "Script Completed in $TimeDiff"
