#+-------------------------------------------------------------+  
#| Author:  Jeremy Rousseau									   |           
#| Purpose: Query AD for inactive accounts by date             |
#| Date: 01-07-2016                                            |
#| Version: 1.0                                                | 
#+-------------------------------------------------------------+

#+-------------------------------------------------------------+  
#| Change Log:												   |
#| Version 1.0 - Initial build                                 |
#+-------------------------------------------------------------+  

#+----------------------------------------------------------------------------------------------------------------------+
#| INSTUCTIONS - PLEASE READ																							|
#|																														|
#| Output will be saved to c:\tmp\ps\results\ ---> You must create this directory										|
#| File name will be AD_Disabled_Users_DATETIME.txt																		|
#|																														|
#| Change search date on line 31, this will search for inactive accounts older than that date							|
#|																														|
#| Run Find_AD_Disabled_User.ps1 from a PowerShell commandline or IDE													|
#|																														|
#+----------------------------------------------------------------------------------------------------------------------+

#Load AD Module for PowerShell
import-module ActiveDirectory

#set search date, inactive accounts older than 'date'
$inactive_date = "mm/dd/yyyy";

$now = get-date -format yyyyMdHHmm;

search-adaccount -AccountInactive -DateTime $inactive_date -usersonly -SearchBase "OU=yours,DC=abc,DC=net" | select-object name,lastlogondate | out-string -stream | select-string -pattern "ilm" -notMatch | select-string -pattern "dispatch" -notMatch | select-string -pattern "expanded" -notMatch | select-string -pattern "detail" -notMatch | select-string -pattern "train" -notMatch > c:\tmp\AD_Disabled_Users_$now.txt
