#################################################################################################
#
#
#
#                            workstation rollout
#                            Author: Andrew Williams
#                            Date Published: 09/01/2016
#
#
#
#################################################################################################

################################# Powershell version check ######################################

$psversion = $PSVersionTable.PSVersion.Major                                                                        #This script requires powershell 3 or higher to work
if ($psversion -lt 3) {                                                                                             #If the current powershell version is lower, the script exits with a warning
    write-warning "This script requires Powershell version 3 or higher."
    write-warning "Please download the newest Windows Management Framework and .net Framework"
    pause
    EXIT
}

#################################################################################################

################################# Network Connection Test #######################################

function Pause {
   Read-Host 'Press Enter to continue…' | Out-Null
}

$domain = "JAGUARS.NET"

if (!(Test-Connection -Computername $domain -BufferSize 16 -Count 1 -Quiet)) {                                      #Test network connection to Jaguars.net
    Write-Host Unable to connect to $domain. Please check your network connection.                                  #If connection fails, inform user and kill script 
    Pause
    EXIT
}
if (!(test-path "C:\Installation_Files")) {                                                                         #If folder not created, create
    mkdir C:\Installation_Files
}
                                                                                       
##################################################################################################

################################# Drive mapping and global variables #############################

$cred = Get-Credential                                                                                              #Get user's credentials, used in next step to map PSDrive
New-PSDrive -name X -psprovider FileSystem -root \\fileserver3.jaguars.net\itfiles -credential $cred                #Create PSDrive, map to X, and point to ITFiles
New-PSDrive -name W -psprovider FileSystem -root \\\\avserver1.jaguars.net\ofcscan -credential $cred                  #PSDrive W needed for TrendMicro install

[string]$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path                                               #Reference to script path
[string]$itfiles = "X:\"                                                                                            #Path to root of PSDrive
[string]$Wallpaper = join-path $itfiles "Desktop Apps\Wallpaper"                                                    #Path to Wallpaper folder
#[string]$Office = join-path $itfiles "Office\off2013"                                                               #Path to Office installation
[string]$TrendMicro = join-path $itfiles "rollout\TrendMicro"                                                       #Path to TrendMicro
[string]$TLS_disable = join-path $itfiles "rollout\scripts"                                                         #Path to TLS_RC4 script
[string]$JagFonts = join-path $itfiles "rollout\fonts\font_rollout"                                                 #Path to fonts folder
[string]$TargetPath = "C:\installation_files"

                                         

##################################################################################################

##################################### Install Office #############################################
<#
Function Install-Office {
    
    param (
       [Parameter(Mandatory=$true, HelpMessage = "Path to folder containing Office install files")][string] $path,
        [Parameter(Mandatory=$true, HelpMessage = "Path of the folder to which files will be copied")][string] $target
    )

    if ((test-path -path $Path -PathType Container)) {
        $title = "Download Office"
        $message = "Do you want to install Office on this machine?"
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
            "Downloads Office 2013 to this machine."
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
            "Does not install Office on this machine."
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no) 
        $result = $host.ui.PromptForChoice($title, $message, $options, 1)
        switch ($result) {
            0 {"You selected Yes."}
            1 {"You selected No."}
        }
        if ($result -eq 0) {
            if (!(test-path $TargetPath\off2013)) {
                write-host Copying installation files now
                Copy-Item -path X:\office\off2013 -Destination C:\Installation_Files -recurse -force
            }
            & 'C:\installation_files\off2013\setup.exe'

        }
    } else {
    write-host Unable to connect to office folder. Moving on.
    }
}
#>
###################################################################################################

###################################### Lockscreen set #############################################

Function Set-LockScreen {
    param (
        [Parameter(Mandatory=$true, HelpMessage = "The Windows Version that you are running the script on")][string] $version
    )

    if ($version -match "6.1.*") {
        write-host "This operating system does not use the lock screen"
        Pause
        return
    }

    $ScreenPath="C:\windows\Web\Screen"
    $SystemData="C:\ProgramData\Microsoft\Windows\SystemData"
    icacls $ScreenPath /t /c /l /q /grant:r Administrators:F
    takeown /f $ScreenPath /a /r /d Y
    if (test-path $SystemData) {
        takeown /f $SystemData /a /r /d Y
        icacls $SystemData /t /c /l /q /grant:r Administrators:F
        Remove-Item $SystemData\s-1-5-18\ReadOnly\LockScreen_Z\*.*
    }
    icacls $SystemData /t /c /l /q /grant:r Administrators:F
    Rename-Item $ScreenPath\img100.jpg -NewName img106.jpg
    Copy-Item C:\wallpaper\img100.jpg $ScreenPath\img100.jpg -Force
}

###################################################################################################

###################################### Set Default Wallpaper ######################################

Function Set-Wallpaper {
    $WallPaper_root = "C:\Windows\Web\Wallpaper"
    $Wallpaper_file = "C:\Windows\Web\Wallpaper\Windows\img0.jpg"
    takeown /f $Wallpaper_root /a /r /d Y
    icacls $Wallpaper_root /t /c /l /q /grant:r Administrators:F
    Rename-Item -path $Wallpaper_file -newName img1.jpg -Force
    Copy-Item C:\Wallpaper\img0.jpg C:\Windows\Web\Wallpaper\Windows -Force 
}

###################################################################################################

###################################### Computer name change #######################################

function Change-Computer {
    $title = "Name change"
    $message = "Do you want to change the computer name? Only for domain joined computers"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Will change a domain joined computer's name."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Does nothing to the computer name."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice($title, $message, $options, 1)
    switch ($result) {
        0 {"You selected Yes."}
        1 {"You selected No."}
    }
    if ($result -eq 0) {
        $ComputerName = Read-Host -Prompt 'Input the computer name'
        Rename-Computer -NewName $ComputerName -DomainCredential $cred
    } else {
        write-host Skipping computer name change
    }
}

###################################################################################################

####################################### Set VPN Connection ########################################

function setup-VPN {
    param (
        [Parameter(Mandatory=$true, HelpMessage = "The Windows Version that you are running the script on")][string] $version
    )

    if ($version -match "6.1.*") {
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Powershell version is too old, you will need to set the VPN connection manually",0,"Done",0x1)
        return
    }

    Add-VPNConnection -Name "Whatever vpn" -ServerAddress "Filler Text" -TunnelType "L2TP" -EncryptionLevel "Optional" -AuthenticationMethod "MSCHAPv2" -AllUserConnection -L2tpPsk "Insert  Key Here"
}

###################################################################################################

######################################### Install Fonts ###########################################

function install-fonts {
    if (test-path $JagFonts) {
        copy-item $JagFonts $TargetPath -recurse -force
        & 'C:\installation_files\font_rollout\add-font.ps1' -path $targetpath\font_rollout\fonts                    #I totally stole the add-font.ps1 script from technet
    }
}

###################################################################################################

###################
#Start Office Install
###################
#Disabled Until 2016 executable is setup/enabled
#Install-Office -path $office -target $TargetPath

###################
#Enable File and Print Sharing
###################
#still works in Win 10
write-output "Enabling File and Print Sharing now"
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes 

###################
#TrendMicro Installation
###################
#AVserver always has up to date installer
write-output "Starting TrendMicro Installation"
& 'W:\autopcc.exe'
write-output "TrendMicro installation has finished"

###################
#Set default login wallpaper
###################

write-host Copying Wallpaper folder to root of C drive
copy-item -path $Wallpaper -destination C:\ -recurse -force
write-host Preparing to set the default wallpaper
Set-Wallpaper

###################
#Set default lock screen
###################

$version = (Get-CimInstance Win32_OperatingSystem).version
write-host Preparing to set the default lockscreen
Set-Lockscreen -version $version

###################
#Change computer name
###################

Change-Computer

###################
#Set VPN Connection
###################

setup-VPN -version $version

###################
#MapMyHdrive
###################

$MapHDrive = 'X:\rollout\MapDrive\MapMyHdrive.bat'
if (test-path $MapHDrive) {
    $Pubdesktop = get-childitem -path C:\users\public -Force -Directory | Where-Object {$_.name -like "*desktop*"}
    if ($Pubdesktop) {
        copy-item $MapHDrive $Pubdesktop.FullName
    } else {
        write-warning "Could not find the Public Desktop" 
    }
} else {
    write-host Attempting to access this file path - $MapHDrive
    write-warning "Could not access MapMyHdrive.bat. Please check that file still exists."
}

###################
#Install Fonts
###################

Install-Fonts

###################
#Remove installation_files folder
###################

Get-ChildItem C:\ | where-object {$_.name -eq "Installation_Files"} | remove-item -recurse

pause
