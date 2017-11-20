get-aduser -filter * -Properties LockedOut | where lockedout -eq true | where name -ne Administrator | select name,lockedout
Write-Host 'If No results shown No accounts are locked out'
Read-Host 'Press Enter to continue… ' | Out-Null