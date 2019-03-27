#This is the file that will be generated with the users account ID and the password generated.
#[String]$path= "c:\test\NewPass.txt"

#This will check if the file exist and will delete that file so a new one can be created from the scratch
#If the doesn't exist will through an error saying that the file doesn't exist and will continue.
#if ($path -ne $null){Remove-Item $path}


<# Required Assembly to Generate Passwords #>
Add-Type -Assembly System.Web
#In my case I created a OU for test purposes here it is.
#You need to change it to meet your requirements.
# Mailbox OU $OU="OU=OldSharedMailboxes,OU=Jaguars.com Accounts,OU=Jaguars,DC=Jaguars,DC=net"
$OU="OU=ExternalUsers,OU=Jaguars,DC=Jaguars,DC=net"
#Get the users inside the OU specified in the Options Above
$users=Get-ADUser -filter * -SearchBase $OU -Properties PasswordNeverExpires|select name,PasswordNeverExpires


#foreach($Name in $users.samaccountname){
#Variable that will receive the random password
#$NewPassword=[Web.Security.Membership]::GeneratePassword(8,3)

#The code below will change the password and will set the Option to change the password on the next logon.
#Set-ADAccountPassword -Identity $Name -cred -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)
#Get-ADUser -Identity $Name |Set-ADUser -ChangePasswordAtLogon:$true

#Here will write the info to the file, so you can communicate to your users the new password.
#Write-Output "UserID:$name `t Password:$NewPassword" `n`n|FT -AutoSize 

#} 