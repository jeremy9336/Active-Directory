<#
.SYNOPSIS
Query AD groups for members

.DESCRIPTION
This PowerShell script will query AD and get a user list from groups

.INPUTS
File selected from dialog input, TXT files only

.OUTPUTS
~Group~_MEMBERS.txt

.EXAMPLE
.\Get_AD_Group_Members.ps1
Execute script from a PowerShell command line(Run as administrator)

.NOTES
Author:  Jeremy Rousseau

Version: 1.2
Date: 07-11-2017

Change Log
Version 1.0 Initial release
Version 1.1 - Add cmd to import AD module
Version 1.2 Added dialog box for file selection

.LINK
None
#>

#Load AD Module for PowerShell
import-module ActiveDirectory

Function Get-FileName($SelectedFile)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
	
	Write-Host "Select input file..."  -ForegroundColor Green
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "TXT (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
	Write-Host "OK, processing file..." -ForegroundColor Green
}

$inputfile = Get-FileName
$outfile = $inputfile+"_MEMBERS.txt"
$date = Get-Date
$list = get-content $inputfile

echo $date | out-file $outfile;

$a = @{Expression={$_.Name};Label="Employee Name"}, `
@{Expression={$_.samaccountname};Label="Account Name"}

foreach ($i in $list )
{$i + "`n" + "===========================";
echo "======================================================" | out-file -append $outfile;
echo $i | out-file -append $outfile;
get-adgroupmember -Identity $i | select-object name,samaccountname | format-table -AutoSize $a | out-file -append $outfile;
}

Write-Host "Script complete!" -BackgroundColor Magenta
Write-Host "Output saved to: " $outfile -ForegroundColor Green