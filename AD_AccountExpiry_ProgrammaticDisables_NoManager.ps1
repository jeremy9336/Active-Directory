# Author:  Jeremy Rousseau
 
# Script: AD_AccountExpiry_ProgrammaticDisables_NoManager.ps1
# Current Version: 2.2
# Published: 15 March 2017
# Revision Date: 06 Oct 2017
 
# Change Log:
# v1.0 - Script creation
# v2.0 - Updated to remove date filter and add logging output
# v2.1 - Updated filtering options
# v2.2 - Added filtering for the onboarding OU

# DESCRIPTION:
# This script queries Active Directory for inactive accounts without supervisor and writes output to CSV

Import-module ActiveDirectory

#Search AD enabled AD accounts with the words "programatically disabled" in the description field
$Date = Get-Date -Format "MM-dd-yyyy" 
$ADPath = "SET-OU-PATH"
$OnboardingOU = '*Onboarding,*'
Get-aduser -SearchBase $ADPath -filter {(enabled -eq $false) -and (description -notlike '*offboarding*')} -properties samaccountname,distinguishedName,name,lastlogontimestamp,office,description,manager | where {($_.manager -eq $null) -and ($_.DistinguishedName -notlike $OnboardingOU)} | Select samaccountname,name,@{N='LastLogonTimestamp'; E={[DateTime]::FromFileTime($_.LastLogonTimestamp)}},office,description | 
Export-Csv -path c:\tmp\ProgramaticDisable_NoManager_Output_$Date.csv -append -notype