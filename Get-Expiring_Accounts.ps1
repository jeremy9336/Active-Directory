# *****************************************************************
# * Get-Expiring_Accounts.ps1
# *****************************************************************
# * Description: Get AD account expiration date, export to CSV
# * Version: 1.0
# *
# * Original Author:  Jeremy Rousseau
# *****************************************************************
# * Version * Date     * Changes
# *****************************************************************
# * 1.0     * 9/28/23  * Jeremy Rousseau - Initial release
#
# Related PowerShell Cmdlets or Scripts
# Set-Account_Expiration_Date.ps1 - Set the expiration date for an AD account.
# Clear-adAccountExpiration - Clear the expiration date for an AD account.

#Set number of days to search forward to get expiring accounts
$DateFilter = (Get-Date).AddDays(90)

#Set applicable AD Path (This can be modified to narrow in updates to a specific OU)
$ADPath = "OU=yours,DC=abc,DC=net"

Get-aduser -filter {(Enabled -eq "True") -and (accountexpires -lt $DateFilter)} -SearchBase $ADPath -Properties samaccountname,name,employeetype,accountexpires |`
where {($_.accountexpires -ne '0') -and ($_.accountexpires -ne '12/31/1600 17:00:00')}|`
Select samaccountname,name,employeetype,@{N='accountexpires'; E={[DateTime]::FromFileTime($_.accountexpires)}} |`
Export-csv c:\tmp\Expiring_Accounts.csv -append -notype