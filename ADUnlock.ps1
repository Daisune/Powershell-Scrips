$Credentials = Get-Credential
$User = Read-Host -Prompt "Input AD User"
$lock = get-aduser $user -Properties LockedOut | select lockedout -OutVariable lock
If ($lock -eq "False") { Write-Output "$user is not locked out" } 
Else {Unlock-ADAccount $user -Credential $Credentials
Write-Output "User should be unlocked now"
get-aduser -filter * -Properties LockedOut | where lockedout -eq true | select name,lockedout
 }