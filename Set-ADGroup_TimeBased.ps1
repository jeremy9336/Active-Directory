#+-------------------------------------------------------------  
#| Purpose: This script sets time-based group membership for a user and then displays new addition.
#| Author:  Jeremy Rousseau
#| Date: 11 May 2023
#| Version: 1.0
#+-------------------------------------------------------------

#+-------------------------------------------------------------  
#| Change Log:												   
#| Version 1.0 - Initial build                                 
#+------------------------------------------------------------- 

### DO 	NOT EDIT BELOW THIS LINE ###

[CmdletBinding()]
param (
	#User
	[parameter(Mandatory = $True)]
	[ValidateNotNullOrEmpty()]
	[string]$User,
	
	#Group
	[parameter(Mandatory = $True)]
	[ValidateNotNullOrEmpty()]
	[string]$Group,

	#Days
	[parameter(Mandatory = $True)]
	[ValidateNotNullOrEmpty()]
	[int]$Days
)

#Set time-to-live
$ttl = New-TimeSpan -End (Get-Date).AddDays($Days)

#Set AD group membership
Add-ADGroupMember -Identity $Group -Members $User -MemberTimeToLive $ttl

#Get AD group membership to verify new addition
Write-Host -ForegroundColor yellow "New group membership, TTL=seconds to removal"
Get-ADGroup $Group -Property member –ShowMemberTimeToLive | Select-Object -ExpandProperty member