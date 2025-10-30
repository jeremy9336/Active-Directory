<#
 
Script: Get-LockedOutUsers.ps1
Author: Jeremy Rousseau
Current Version: 1.0

Change Log:
v1.0 - 22 Feb 2024 - Script creation

DESCRIPTION:
Get enabled users that are locked out
Display locked out and if SmartCardLogonRequire
#>

##### DO NOT MODIFY CODE BELOW THIS LINE #####

# Clear variables
$searchBase = $null
$searchBases = $null

# Set SearchBase
$searchBases = @(
    'OU=yours,DC=abc,DC=net',
    'OU=Admins,DC=abc,DC=net'
    )

write-host "Getting locked out users..." -ForegroundColor Yellow
# Get locked-out users
$lockedOutUsers = foreach ($searchBase in $searchBases) {Get-AdUser -SearchBase $searchBase -Filter {(Enabled -eq $True)} -Properties SamAccountName, LockedOut, SmartcardLogonRequired |
                   Where-Object { $_.LockedOut -eq $true }}

# Display the locked-out users
foreach ($user in $lockedOutUsers) {
    Write-Host "User: $($user.SamAccountName) is locked out, SmartCardLogonRequire = $($user.SmartcardLogonRequired)"
}