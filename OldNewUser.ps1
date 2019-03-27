## Defining PARAMS
Param (
[string]$FirstName,
[string]$LastName,
[string]$LikeUN,  #
[string]$UPN = "@nfl.jaguars.com",
[string]$NTDomain = "JAGUARS",
[string]$EmailDomain = "@nfl.jaguars.com"
)
cls
Write-Host "********************************************************************"
Write-Host "**            SeraCare New User Creation Script                   **"
Write-Host "********************************************************************"
If ($FirstName -eq "")
{ $FirstName = (Read-Host "First Name")
}
If ($LastName -eq "")
{ $LastName = (Read-Host "Last Name")
}
If ($LikeUN -eq "")
{ $LikeUN = (Read-Host "Security 'like' User Name")
}
Write-Host "`First Name:`t`t$FirstName"
Write-Host "Last Name:`t`t$LastName"
Write-Host "Security 'Like':`t$LikeUN"
$Answer = Read-Host "Is this the information you want to use (y/N)"
If ($Answer.ToUpper() -ne "Y")
{ Write-Host "`n`nOK.  Please rerun the script and reenter the data correctly.`n"
Break
}
$TempUN = $FirstName.SubString(0,1)+$LastName
$Mimic = (Read-Host -Prompt 'User being Copied')
Do {
$User = $null
Write-Host "If you see an error message here, that's ok..."
$User = Get-ADUser $TempUN -ErrorAction SilentlyContinue
If ($User)
{ Write-Host "Username: $TempUN already exists"
$TempUN = (Read-Host "Enter user name manually")
}
Else
{ $UserName = $TempUN
}
} Until ($UserName -ne $null)
$TempUN = $LikeUN
Do {
$User = $null
Write-Host "If you see an error message here, that's ok..."
$User = Get-ADUser $TempUN -ErrorAction SilentlyContinue
If (-not ($User))
{ Write-Host "Username: $TempUN doesn't exist"
$TempUN = (Read-Host "Enter user name manually")
}
Else
{ $LikeUserName = $TempUN
}
} Until ($LikeUserName -ne $null)
Get-ADUser $Mimic | New-ADUser -Givenname "New" -SurName "User"
$LikeUN = $LikeUser.DistinguishedName | Out-String
$OU = $LikeUN.Substring($LikeUN.IndexOf("OU="))
$LikeUser = Get-ADUser $LikeUserName -Properties MemberOf,Title,Office,Manager,Department,ScriptPath,HomeDirectory
$UPN = $UserName+$UPN
$LikeUN = $LikeUser.DistinguishedName | Out-String
$OU = $LikeUN.Substring($LikeUN.IndexOf("OU="))
$LikeUser | New-ADUser -GivenName $FirstName -Surname $LastName -Name "$LastName, $FirstName" -SamAccountName $UserName -UserPrincipalName $UPN -Path $OU -AccountPassword $Password
ForEach ($Group in ($LikeUser.MemberOf))
{ Add-ADGroupMember $Group $UserName
}
$HomePath = ($LikeUser.HomeDirectory).SubString(0,($LikeUser.HomeDirectory).IndexOf("\$($LikeUser.SamAccountName)"))
New-Item -Name $UserName -ItemType Directory -Path $HomePath | Out-Null
Set-ADUser $UserName -HomeDirectory "$HomePath\$UserName" -HomeDrive H:
$ACL = Get-Acl "$HomePath\$UserName"
$ACL.SetAccessRuleProtection($true, $false)
$ACL.Access | ForEach { [Void]$ACL.RemoveAccessRule($_) }
$ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDomain\Domain Admins","FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")))
$ACL.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("$NTDomain\$UserName","Modify", "ContainerInherit, ObjectInherit", "None", "Allow")))
Set-Acl "$HomePath\$UserName" $ACL