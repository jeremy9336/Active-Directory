#+-------------------------------------------------------------  
#| Purpose: Find DN that has a Slash \
#| Author:  Jeremy Rousseau
#| Date: 05-30-2024
#| Version: 1.0
#+-------------------------------------------------------------

#+-------------------------------------------------------------  
#| Change Log:												   
#| Version 1.0 - Initial build                                 
#+------------------------------------------------------------- 

### DO 	NOT EDIT BELOW THIS LINE ###

Get-ADuser -Filter * -SearchBase "DC=abc,DC=net" -Properties * | where {$_.distinguishedName -like "*\*"}  | select name | ft -auto