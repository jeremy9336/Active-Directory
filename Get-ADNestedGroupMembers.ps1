#+-------------------------------------------------------------  
#| Purpose: Get AD Nested AD Group Members
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
  [String] $Group_Name
)

Function Group_Status
{
Write-Host -ForegroundColor yellow 'User-object Members'
Get-ADGroupMember -Identity $Group_Name |  where-object objectClass -like user | Select-Object Name,samAccountName,objectClass | Sort-Object Name | ft -AutoSize

Write-Host -ForegroundColor yellow 'Group-object Members'
Get-ADGroupMember -Identity $Group_Name |  where-object objectClass -like group | Select-Object Name,objectClass,DistinguishedName | Sort-Object Name | ft -AutoSize

Write-Host -ForegroundColor yellow 'All nested Users'
Get-ADGroupMember -Identity $Group_Name -Recursive | where-object objectClass -like user | Select-Object Name,samAccountName,objectClass | Sort-Object Name | ft -AutoSize
}

Group_Status



