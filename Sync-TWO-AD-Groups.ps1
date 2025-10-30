#+-------------------------------------------------------------  
#| Purpose: Sync AD 'Group B' from 'Group A'
#| Author:  Jeremy Rousseau
#| Date: 02-05-2024
#| Version: 1.0
#+-------------------------------------------------------------

#+-------------------------------------------------------------  
#| Change Log:												   
#| Version 1.0 - Initial build                                 
#+------------------------------------------------------------- 

### DO 	NOT EDIT BELOW THIS LINE ###

Param(
  [String] $Group_A,
  [String] $Group_B
)

$AddMembers = Get-ADGroupMember -Identity $Group_A -Recursive | where-object objectClass -like user | Select-Object samAccountName
Add-ADGroupMember -Identity $Group_B -Members $AddMembers
Write-Host -ForegroundColor yellow 'Added members from nested groups'

Write-host AD A membership: (Get-ADGroup $Group_A -Properties *).Member.Count
Write-host AD B membership: (Get-ADGroup $Group_B -Properties *).Member.Count