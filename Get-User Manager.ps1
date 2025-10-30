#+-------------------------------------------------------------  
#| Purpose: Get User's Manager
#| Author:  Jeremy Rousseau
#| Date: 10-05-2022
#| Version: 1.0
#+-------------------------------------------------------------

#+-------------------------------------------------------------  
#| Change Log:												   
#| Version 1.0 - Initial build                                 
#+------------------------------------------------------------- 

### DO 	NOT EDIT BELOW THIS LINE ###

#Display script begging time
[string]$BeginTime = Get-Date -format HH:mm:ss
Write-Host -ForegroundColor Green "Beginning script at $BeginTime"

# Load AD Module for PowerShell
Import-Module ActiveDirectory

# Get user list  
$users = Get-Content -path C:\tmp\PS\scripts\users.txt

# Sort users
$users = $users | Sort-Object

# Eport file
$outfile = 'C:\tmp\PS\scripts\export.csv'

# loop through users
Foreach ($i in $users) {

# Write Details
  Write-Host "Getting info... - $i" -foregroundcolor "magenta"

# Pull information from AD for each user
Get-ADUser -filter 'samaccountname -like $i' -properties * -ErrorAction SilentlyContinue | select Name, EmailAddress, State, Department, Office, `
@{N='Manager';E={(Get-ADUser $_.Manager).Name}}, `
@{Name="ManagerEmail";Expression={(get-aduser -property Displayname,emailaddress $_.manager).emailaddress}} | `
# Export to outfile
ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | out-file -filepath $outfile -append

}

#Calculate and display how long it took script to complete
[string]$EndTime = Get-Date -format HH:mm:ss
Write-Host -ForegroundColor Green "Script Completed at $EndTime"
[string]$TimeDiff = New-TimeSpan -Start $BeginTime -End $EndTime
Write-Host -ForegroundColor Green "Script Completed in $TimeDiff"