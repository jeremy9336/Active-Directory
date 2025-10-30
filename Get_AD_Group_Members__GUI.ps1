<#
.SYNOPSIS
Query AD groups for members

.DESCRIPTION
This PowerShell script will query AD and get a user list from groups

.INPUTS

.OUTPUTS

.EXAMPLE
.\Get_AD_Group_Members__GUI.ps1
Execute script from a PowerShell command line(Run as administrator)

.NOTES
Author:  Jeremy Rousseau

Version: 1.3
Date: 07-13-2017

Change Log
Version 1.0 Initial release
Version 1.1 - Add cmd to import AD module
Version 1.2 Added dialog box for file selection
Version 1.3 Added GUI interface

.LINK
None
#>

#Create form
Add-Type -AssemblyName System.Windows.Forms

$h_name = hostname
$Get_AD_Grp_Mbrs = New-Object system.Windows.Forms.Form
$Get_AD_Grp_Mbrs.Text = $h_name
$Get_AD_Grp_Mbrs.BackColor = "#1923dd"
$Get_AD_Grp_Mbrs.TopMost = $true
$Get_AD_Grp_Mbrs.Width = 400
$Get_AD_Grp_Mbrs.Height = 150

$Logo = New-Object system.windows.Forms.PictureBox
$Logo.ImageLocation = "LOGO.png"
$Logo.Height = 64
$Logo.Width = 73
$Logo.location = new-object system.drawing.point(300,10)
$Get_AD_Grp_Mbrs.controls.Add($Logo)

#Button - Select File
$Button_Select_File = New-Object system.windows.Forms.Button
$Button_Select_File.BackColor = "#c9c7d6"
$Button_Select_File.Text = "Select File"
$Button_Select_File.Width = 60
$Button_Select_File.Height = 40
$Button_Select_File.Add_Click({

#Function - Select File
Function Get-FileName($SelectedFile)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
	
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "TXT (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

#Run function and create input file variable
$inputfile = Get-FileName

#If variable is empty return to script(no error)
if (!$inputfile) { return }

#Output file
$outfile = $inputfile+"_MEMBERS.txt"

#Get date and ammend to output file
$date = Get-Date
echo $date | out-file $outfile;

#Get content from input file
$list = get-content $inputfile

$a = @{Expression={$_.Name};Label="Employee Name"}, `
@{Expression={$_.samaccountname};Label="Account Name"}

#Popup - Script is running
(new-object -ComObject wscript.shell).Popup("The script is running, please wait, you'll be notified when it has completed",15,"Attention: Script Running")

#Load AD Module for PowerShell
import-module ActiveDirectory

foreach ($i in $list )
{$i + "`n" + "===========================";
echo "======================================================" | out-file -append $outfile;
echo $i | out-file -append $outfile;
get-adgroupmember -Identity $i | select-object name,samaccountname | format-table -AutoSize $a | out-file -append $outfile;
}

#Popup - Scipt is complete
(new-object -ComObject wscript.shell).Popup("The script has completed, saved to: $outfile",0,"Attention: Script Complete")
})
$Button_Select_File.location = new-object system.drawing.point(10,50)
$Button_Select_File.Font = "Microsoft Sans Serif,10,style=Bold"
$Get_AD_Grp_Mbrs.controls.Add($Button_Select_File)

#Button - Help
$Button_Help = New-Object system.windows.Forms.Button
$Button_Help.BackColor = "#c9c7d6"
$Button_Help.Text = "Help"
$Button_Help.AutoSize = $true
$Button_Help.Width = 60
$Button_Help.Height = 40
$Button_Help.Add_Click({
(new-object -ComObject wscript.shell).Popup("Step 1: Click the 'Select File button'`nStep 2: Select the TXT file that contains AD groups and select 'Open'`nStep 3: The script will process the selected file and save it to the same directory with '_MEMBERS.txt' amended to the end. You will be notified once the script is complete.",0,"Help: Get AD Group Members")
})
$Button_Help.location = new-object system.drawing.point(160,50)
$Button_Help.Font = "Microsoft Sans Serif,10,style=Bold"
$Get_AD_Grp_Mbrs.controls.Add($Button_Help)

#Button - Exit
$Button_Exit = New-Object system.windows.Forms.Button
$Button_Exit.BackColor = "#c9c7d6"
$Button_Exit.Text = "Exit"
$Button_Exit.AutoSize = $true
$Button_Exit.Width = 60
$Button_Exit.Height = 40
$Button_Exit.Add_Click({
$Get_AD_Grp_Mbrs.Close()
})
$Button_Exit.location = new-object system.drawing.point(233,50)
$Button_Exit.Font = "Microsoft Sans Serif,10,style=Bold"
$Get_AD_Grp_Mbrs.controls.Add($Button_Exit)

#Lable - Top
$Lable_Top = New-Object system.windows.Forms.Label
$Lable_Top.BackColor = "#c9c7d6"
$Lable_Top.Text = $h_name
$Lable_Top.AutoSize = $true
$Lable_Top.Width = 25
$Lable_Top.Height = 10
$Lable_Top.location = new-object system.drawing.point(10,10)
$Lable_Top.Font = "Microsoft Sans Serif,18,style=Bold"
$Get_AD_Grp_Mbrs.controls.Add($Lable_Top)

[void]$Get_AD_Grp_Mbrs.ShowDialog()
$Get_AD_Grp_Mbrs.Dispose()