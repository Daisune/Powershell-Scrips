$AdminPass = Get-Credential -Message "Admin Account with AD creation rights"
$OG = (Read-Host -Prompt 'Account w/ Memberships Being Copied')
$AC = (Read-Host -Prompt 'Account recieving Memberships')
Get-ADUser -Identity $OG -Credential $AdminPass -Properties memberof |Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $AC