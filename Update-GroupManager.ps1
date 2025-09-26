#+-------------------------------------------------------------+  
#| Author:  Jeremy Rousseau
#| Purpose: Updates Group Manager / Owner and checks the "Group Manager can update list"
#| Date: 04-02-2020
#| Version: 1.0
#+--------------------------------------------------------------

#+-------------------------------------------------------------+  
#| Change Log:
#| Version 1.0 - Initial script
#+-------------------------------------------------------------+

param(
    [Parameter(Mandatory=$true)]
    [string[]]$Groups,
    [Parameter(Mandatory=$true)]
    [string[]]$NewMgr
)

foreach ($group in $groups)
{
    try {
        $Grp = Get-ADGroup $group -Properties managedby

        # If group has a current manager - Removes the manager and deletes the DSACL
        If ($grp.managedby -ne $null) {
            $OldMgr = ($Grp.managedby -split ",")[0].Substring(3)
            $OldMgrSam = Get-ADUser -Filter {name -eq $OldMgr} | select SamAccountName -ExpandProperty SamAccountName

        }

    }
    catch {
        Write-Host $group is not a valid group name -ForegroundColor Red
    }
}
