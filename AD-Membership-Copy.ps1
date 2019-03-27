$AdminPass = Get-Credential -Message "Account with AD creation rights"
$OG = (Read-Host -Prompt 'Account Being Copied')
$SAM = (Read-Host -Prompt 'User recieving groups')
Get-ADUser -Identity $OG -Credential $AdminPass -Properties memberof |Select-Object -ExpandProperty memberof | Add-ADGroupMember -Credential $AdminPass -Members $SAM