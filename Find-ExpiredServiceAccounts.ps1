#+-------------------------------------------------------------  
#| Purpose: Find Expired Service Accounts
#| Author:  Jeremy Rousseau
#| Date: 07-19-2022
#| Version: 1.0
#+-------------------------------------------------------------

#+-------------------------------------------------------------  
#| Change Log:												   
#| Version 1.0 - Initial build                                 
#+------------------------------------------------------------- 

# Set days to ignore
$StaleDate = (Get-Date).AddDays(-67)

$All = Get-ADUser -filter {Enabled -EQ "True"} -SearchBase "DC=abc,DC=net" -properties LastLogonDate,PasswordLastSet,manager
$a = $ALL | Where-Object {$_.PasswordLastSet -LT $StaleDate}
$a | Select SamAccountName,PasswordLastSet,LastLogonDate,@{Name='Manager';Expression={(Get-ADUser ($_.Manager)).SAMAccountname}}
