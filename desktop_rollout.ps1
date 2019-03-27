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

if (!(Test-Connection -Computername $domain -BufferSize 16 -Count 1 -Quiet)) {                                      #Test network connection to Domain
    Write-Host Unable to connect to $domain. Please check your network connection.                                  #If connection fails, inform user and kill script 
    Pause
    EXIT
}
if (!(test-path "C:\Installation_Files")) {                                                                         #If folder not created, create
    mkdir C:\Installation_Files
}
                                                                                       
##################################################################################################

################################# Drive mapping and global variables #############################
    
$cred = Get-Credential                                                                                          #Get user's credentials, used in next step to map PSDrive
New-PSDrive -name X -psprovider FileSystem -root \\fileserver3.jaguars.net\itfiles -credential $cred                #Create PSDrive, map to X, and point to ITFiles
New-PSDrive -name W -psprovider FileSystem -root \\avserver1.jaguars.net\ofcscan -credential $cred                  #PSDrive W needed for TrendMicro install

[string]$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path                                               #Reference to script path
[string]$itfiles = "X:\"                                                                                            #Path to root of PSDrive
[string]$Wallpaper = join-path $itfiles "Desktop Apps\Wallpaper"                                                    #Path to Wallpaper folder
[string]$Office = join-path $itfiles "Office\Off365"                                                               #Path to Office installation
[string]$TrendMicro = join-path $itfiles "rollout\TrendMicro"                                                       #Path to TrendMicro
[string]$TLS_disable = join-path $itfiles "rollout\scripts"                                                         #Path to TLS_RC4 script
[string]$JagFonts = join-path $itfiles "rollout\fonts\font_rollout"                                                 #Path to fonts folder
[string]$TargetPath = "C:\installation_files"

                                         

##################################################################################################

##################################### Install Office #############################################

Function Install-Office {
    
    param (
       [Parameter(Mandatory=$true, HelpMessage = "Path to folder containing Office install files")][string] $path,
        [Parameter(Mandatory=$true, HelpMessage = "Path of the folder to which files will be copied")][string] $target
    )

    if ((test-path -path $Path -PathType Container)) {
        $title = "Download Office"
        $message = "Do you want to install Office on this machine?"
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
            "Downloads Office 2016 to this machine."
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
            "Does not install Office on this machine."
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no) 
        $result = $host.ui.PromptForChoice($title, $message, $options, 1)
        switch ($result) {
            0 {"You selected Yes."}
            1 {"You selected No."}
        }
        if ($result -eq 0) {
            if (!(test-path $TargetPath\off365)) {
                write-host Copying installation files now
                Copy-Item -path X:\office\off365 -Destination C:\Installation_Files -recurse -force
            }
            & 'C:\installation_files\off365\setup.exe' /configure c:\installation_files\off365\Config.xml

        }
    } else {that 
    write-host Unable to connect to office folder. Moving on.
    }
}


## ==============================================
## Show Desktop Icons (My PC & Control Panel)
## ==============================================

$ErrorActionPreference = "SilentlyContinue"
If ($Error) {$Error.Clear()}
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
If (Test-Path $RegistryPath) {
	$Res = Get-ItemProperty -Path $RegistryPath -Name "HideIcons"
	If (-Not($Res)) {
		New-ItemProperty -Path $RegistryPath -Name "HideIcons" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check = (Get-ItemProperty -Path $RegistryPath -Name "HideIcons").HideIcons
	If ($Check -NE 0) {
		New-ItemProperty -Path $RegistryPath -Name "HideIcons" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
}
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons"
If (-Not(Test-Path $RegistryPath)) {
	New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "HideDesktopIcons" -Force | Out-Null
	New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons" -Name "NewStartPanel" -Force | Out-Null
}
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
If (-Not(Test-Path $RegistryPath)) {
	New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons" -Name "NewStartPanel" -Force | Out-Null
}
If (Test-Path $RegistryPath) {
	## -- My Computer
	$Res = Get-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
	If (-Not($Res)) {
		New-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check = (Get-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}")."{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
	If ($Check -NE 0) {
		New-ItemProperty -Path $RegistryPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	## -- Control Panel
	$Res = Get-ItemProperty -Path $RegistryPath -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
	If (-Not($Res)) {
		New-ItemProperty -Path $RegistryPath -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check = (Get-ItemProperty -Path $RegistryPath -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}")."{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
	If ($Check -NE 0) {
		New-ItemProperty -Path $RegistryPath -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	<## -- User's Files
	$Res = Get-ItemProperty -Path $RegistryPath -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
	If (-Not($Res)) {
		New-ItemProperty -Path $RegistryPath -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check = (Get-ItemProperty -Path $RegistryPath -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}")."{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
	If ($Check -NE 0) {
		New-ItemProperty -Path $RegistryPath -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}

## -- Recycle Bin
	$Res = Get-ItemProperty -Path $RegistryPath -Name "{645FF040-5081-101B-9F08-00AA002F954E}"
	If (-Not($Res)) {
		New-ItemProperty -Path $RegistryPath -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check = (Get-ItemProperty -Path $RegistryPath -Name "{645FF040-5081-101B-9F08-00AA002F954E}")."{645FF040-5081-101B-9F08-00AA002F954E}"
	If ($Check -NE 0) {
		New-ItemProperty -Path $RegistryPath -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	## -- Network
	$Res = Get-ItemProperty -Path $RegistryPath -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
	If (-Not($Res)) {
		New-ItemProperty -Path $RegistryPath -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
	$Check = (Get-ItemProperty -Path $RegistryPath -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}")."{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
	If ($Check -NE 0) {
		New-ItemProperty -Path $RegistryPath -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Value "0" -PropertyType DWORD -Force | Out-Null
	}
##>	
}
If ($Error) {$Error.Clear()}


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

    Add-VPNConnection -Name "Jaguars VPN" -ServerAddress "APN.jaguars.com" -TunnelType "L2TP" -EncryptionLevel "Optional" -AuthenticationMethod "MSCHAPv2" -AllUserConnection -L2tpPsk "06F06573072C8A9A"
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
Install-Office -path $office -target $TargetPath

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