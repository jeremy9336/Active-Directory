#+-------------------------------------------------------------  
#| Purpose: Find AD Username that is ALL UPERCASE
#| Author:  Jeremy Rousseau
#| Date: 07-19-2022
#| Version: 1.0
#+-------------------------------------------------------------

#+-------------------------------------------------------------  
#| Change Log:												   
#| Version 1.0 - Initial build                                 
#+------------------------------------------------------------- 

### DO 	NOT EDIT BELOW THIS LINE ###

#Load AD Module for PowerShell
import-module ActiveDirectory

$now = get-date -format yyyyMdHHmm;
get-aduser -filter '*' -searchbase "OU=yours,DC=abc,DC=net" | select-object -expandproperty samaccountname | out-string -stream | select-string -pattern "[A-Z]" -caseSensitive > c:\tmp\ps\results\AD_Uppercase_$now.txt;