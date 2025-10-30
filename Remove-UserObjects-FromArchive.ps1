#+-------------------------------------------------------------  
#| Purpose: This script removes user objects from 'Users_Archive' where user has not logged on in 3 years(1095 days)
#| Author:  Jeremy Rousseau
#| Date: 09 Aug 2023
#| Version: 1.0
#+-------------------------------------------------------------

#+-------------------------------------------------------------  
#| Change Log:												   
#| Version 1.0 - Initial build                                 
#+------------------------------------------------------------- 

### DO 	NOT EDIT BELOW THIS LINE ###

#Enter years in days
$date = (Get-Date).AddDays(-1095)

#Define logging
$LogDate = Get-Date -Format "ddMMMyyyy"
$OutputFile = "C:\tmp\DeleteUsersLog_$LogDate.txt"

#Count the number of user objects to be deleted
write-host "Getting user count...please wait"
$count = (Get-ADUser -SearchBase "OU=Users_Archive,DC=abc,DC=net" -Filter '*' -Properties SamAccountName, LastLogonDate  | Where-Object LastLogonDate -lt $date | Select-Object SamAccountName).count

#Clear deletedCount
$deletedCount = 0

#Report number of possible deletes
Write-Host "This will delete $count user objects from Users Archive" -ForegroundColor Yellow

#Confirm
while($true) {
    $readHostValue = Read-Host -Prompt "Enter Yes or No"
    switch ($readHostValue) {
        #If YES do this
        'Yes' {
            #Confirmed delete
            Write-Host 'CONFIRMED' -ForegroundColor Green
            Write-Host 'Beginning deleting, this will take a few minutes...' 

            #Get user objects to delete, only from Users Archive
            $DeleteUser = Get-ADUser -SearchBase "OU=Users_Archive,DC=abc,DC=net" -Filter '*' -Properties SamAccountName, LastLogonDate  | Where-Object LastLogonDate -lt $date | Select-Object SamAccountName

            #Run through deletion
            Foreach ($User in $DeleteUser) {
            try {
                #Delete user object
                Remove-ADUser $User.SamAccountName -confirm:$False
                #Log the action
                "Deleted user $User" | Out-File -FilePath $OutputFile -Append
                #Count
                $deletedCount++
                }
            catch {
                #Log the action
                Write-Host 'Error - Review log' -ForegroundColor Red
                $_.Exception.Message | Out-File -FilePath $OutputFile -Append
                }
            }
    
            #Report on actual deleted numbers
            write-host "Deleted $deletedCount"
            return #Exits the script
        }

        #If NO then quit
        'No' {
            #Confirm cancel
            Write-Host 'CANCELLED' -ForegroundColor Red
            return #Exits the script
        }

        #Loop for those that can't read
        Default {
            Write-Host "Invalid Input"
        }
    }
}