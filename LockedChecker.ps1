get-aduser -filter * -Properties LockedOut | where lockedout -eq true | select name,lockedout | ft

Read-Host 'Press Enter to continue…' | Out-Null