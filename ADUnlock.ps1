$Credentials = Get-MyCredential (join-path ($PsScriptRoot) Syncred.xml)
$User = Read-Host -Prompt "Input AD User"
$lock = get-aduser $user -Properties LockedOut | select lockedout -OutVariable lock
If ($lock -eq "False") { Write-Output "$user is not locked out" } 
Else {Unlock-ADAccount $user -Credential $Credentials
Write-Output "User should be unlocked now"
get-aduser $user -Properties LockedOut | select lockedout
 }