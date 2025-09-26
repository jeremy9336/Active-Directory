# Author:  Jeremy Rousseau
 
# Script: AD_EmailAccountExpiry_Expiring45.ps1
# Current Version: 1.2
# Published: 12 Sep 2017
# Revision Date: 30 May 2018
 
# Change Log:
# v1.0 - Script creation
# v1.1 - Updated to include logging output
# v1.2 - Added disclaimer text to top of message
# v1.3 - Added check if manager field is null to eliminate accounts with empty supervisor field

# DESCRIPTION:
# This script queries Active Directory for enabled accounts that expire within a given time period and triggers email notification to user & listed manager

Import-module ActiveDirectory

#Search AD enabled AD accounts  and expiration date within 45 days
$Date = Get-Date -Format "MM-dd-yyyy"
$DateFilter = (Get-Date).AddDays(45)
$ADPath = "SET-OU-PATH"
$AcsExp = Get-aduser -SearchBase $ADPath -filter {(Enabled -eq "True") -and (accountexpires -lt $DateFilter)} -properties employeetype,Name,office,whencreated,accountexpires,name,Samaccountname,userprincipalname,manager,description | where {($_.accountexpires -ne '0') -and ($_.accountexpires -ne '12/31/1600 17:00:00')}

#Looping through each for email
 ForEach ($AcExp in $AcsExp)
 {
    #Set account specific variables
	$UserType = $AcExp.EmployeeType
	$UserCreateDate = $AcExp.whencreated
	$UserExpDate = [datetime]::FromFileTime($AcExp.accountexpires)
	$UserDisplayName = $AcExp.Name
	$UserSAM = $AcExp.Samaccountname
    $UserOrgCode = $AcExp.office
	$UserEmail = $AcExp.userprincipalname
	$UserDescrip =  $AcExp.description
	$Manager = $AcExp.manager
	$ManagerFullName = (Get-Aduser -Filter {DistinguishedName -eq $Manager} -Properties *).name
	$ManagerEmail = (Get-Aduser -Filter {DistinguishedName -eq $Manager} -Properties *).userprincipalname
	
	#Set SMTP variables
	$SMTPServer = "SET-SERVER"
	$FromUsrEmail = "SET-FROM-EMAIL"
	$Subject = "Account $UserSAM for $UserDisplayName will expire & become DISABLED on $UserExpDate"
	$Body = "<b>** This is an auto-generated message and does not check for previous submissions. Replies to this message may not be read. **</b><br>
	<br>
	The account <i>$UserSAM</i> for $UserDisplayName must be verified as a valid account to continue the account's usage beyond $UserExpDate. Please do one of the following: <br>
	<br>
	1) If access needs to be extended, please submit an <i>Employee Enable-Disable</i> ticket and provide the new end date.<br>
	<br>
	2) If the individual will be leaving after the end date but will return the following season, please submit an <i>Employee Enable-Disable</i> ticket, and add a note of intent to return.<br>
	<br>
	3) If the individual will not return after the end date, please submit an <i>Employee Offboarding</i> ticket.<br>
	<br>
	4) If the individual is now in a permanent position , please submit an <i>Employee Transfer</i> ticket.<br>
	<br>
	Account: $UserSAM<br>
	Full Name:  $UserDisplayName<br>
	Description: $UserDescrip <br>
	Account Type: $UserType <br>
	Employee Start Date: $UserCreateDate<br>
	Expected End Date: $UserExpDate<br>
	Listed Manager: $ManagerFullName<br>
	<br>
	<i>If you submitted a ticket for this person already after receiving this message previously, no need to submit another. We are working through the tickets & appreciate your patience.</i><br>
	<br>
	If you have any questions/concerns regarding this effort, please contact the Helpdesk"

	If ($Manager -ne $null)
	{
		#Send email 
		Send-MailMessage -to $ManagerEmail -cc $UserEmail -from $FromUsrEmail -subject $Subject -SmtpServer $SMTPServer -bodyashtml $Body
		Write-host $Subject
	}
	else
	{
		#Send email 
		Send-MailMessage -to $UserEmail -from $FromUsrEmail -subject $Subject -SmtpServer $SMTPServer -bodyashtml $Body
		Write-host $Subject
	}
	
    #Create custom PSObject & write output to CSV
   	$row = New-Object PSObject -Property @{
			'samaccountname'= $UserSAM
            'displayname' =  $UserDisplayName
            'OrgCode' = $UserOrgCode
            'Description' =  $UserDescrip
			'LastLogon' = $UserLastLogonTimestamp
    		'Manager' = $ManagerFullName
	    	}

    $row | Export-Csv -path C:\tmp\Expiring_Accounts_$Date.csv -append -notype

	$Manager = $null
	$ManagerFullName = $null
	$ManagerEmail = $null
 }
