$Credentials = Get-Credential -UserName njonesadmin -Message ' '
$User = Read-Host -Prompt "Input AD User"
$lock = get-aduser $user -Properties LockedOut | select lockedout -OutVariable $lock
If ($lock -eq "False") { Write-Output "$user is not locked out" } 
Else {Unlock-ADAccount $user -Credential $Credentials
Write-Output "User should be unlocked now"

get-aduser -filter * -Properties LockedOut | where lockedout -eq true | where name -ne Administrator | select name,lockedout -OutVariable $lock
write-host $lock
Read-Host 'Press Enter to continue…' | Out-Null
 }
