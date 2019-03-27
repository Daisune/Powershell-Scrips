$csv = Import-Csv c:\test\PCLIST2.csv
$Cred=Get-Credential
 foreach ($line in $csv) {
    Get-WmiObject Win32_quickfixengineering -Credential $Cred -ComputerName $line.Test|select PSCopmutername,Installedon,HotfixID,Description|export-csv c:\test\Hotfix_status.csv -Append
}l