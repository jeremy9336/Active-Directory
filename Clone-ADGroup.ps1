#+-------------------------------------------------------------  
#| Purpose: Clone AD Group
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
  [String] $Old_Group_Name,
  [String] $New_Group_Name
)

Function Original_Group_Status
{
Write-Host -ForegroundColor yellow 'Orginal group user-object Members'
Get-ADGroupMember -Identity $Old_Group_Name |  where-object objectClass -like user | Select-Object Name,samAccountName,objectClass | Sort-Object Name | ft -AutoSize

Write-Host -ForegroundColor yellow 'Orginal group-object Members'
Get-ADGroupMember -Identity $Old_Group_Name |  where-object objectClass -like group | Select-Object Name,objectClass,DistinguishedName | Sort-Object Name | ft -AutoSize

Write-Host -ForegroundColor yellow 'All nested Users'
Get-ADGroupMember -Identity $Old_Group_Name -Recursive | where-object objectClass -like user | Select-Object Name,samAccountName,objectClass | Sort-Object Name | ft -AutoSize
}

Function Clone_Group
{
$Old_Group = Get-ADGroup "$Old_Group_Name"

If ($Old_Group -Eq $Null)
{
    "Cannot Clone Non-Existent Group ($Old_Group_Name)"
}
Else
{
    $Old_Group_Scope=$Old_Group.Groupscope
    $Old_Group_Dn=$Old_Group.Distinguishedname
    $Temp=$Old_Group_Dn.Indexof(",")
    $Old_Group_Path=$Old_Group_Dn.Substring($Temp+1,$Old_Group_Dn.Length-$Temp-1)

    New-ADGroup -Name $New_Group_Name -Groupscope 'abc' -Path "OU=x,DC=abc,DC=net"
    
    $a = Get-ADGroupMember -Identity $Old_Group_Name
    ForEach ($b in $a) { 
    get-aduser -Identity $b -Properties * | Where { $_.Enabled -eq $True} | Where-Object {$_.extensionAttribute13 -notlike '3*'}  | Select-Object samaccountname | Add-ADprincipalGroupMembership -Memberof $New_Group_Name
    }
    
    $New_Group=Get-ADGroup -Filter { Name -Like $New_Group_Name }
    If ($New_Group -Eq $Null)
    {
        "Error Creating Group ($New_Group_Name)"
    }
    Else
    {
        write-host -ForegroundColor yellow Created New Group: $New_Group_Name
    }
}
}

Function Flatten_Group
{
$AddMembers = Get-ADGroupMember -Identity $New_Group_Name -Recursive | where-object objectClass -like user | Select-Object samAccountName
Add-ADGroupMember -Identity $New_Group_Name -Members $AddMembers
Write-Host -ForegroundColor yellow 'Added members from nested groups'

$RemoveGroups = Get-ADGroupMember -Identity $New_Group_Name | where-object objectClass -like group | Select-Object Name
ForEach ($b_group in $RemoveGroups) {
    Remove-ADGroupMember -Identity $New_Group_Name -Members $b_group.name -Confirm:$false
    }
}

Function New_Group_Status
{
Write-Host ' '
Write-Host -ForegroundColor yellow 'Users of new group'
Get-ADGroupMember -Identity $New_Group_Name -Recursive | Select-Object Name,samAccountName,objectClass | Sort-Object Name | ft -AutoSize
}

#Run functions
Original_Group_Status
Clone_Group
Flatten_Group
New_Group_Status