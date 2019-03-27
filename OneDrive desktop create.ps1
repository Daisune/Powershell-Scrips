if (!(test-Path  "c:\users\$env:USERNAME\OneDrive - Khan Sports and Entertainment Group\Desktop"))
{
    mkdir -Path "c:\users\$env:USERNAME\OneDrive - Khan Sports and Entertainment Group\Desktop"
    Set-Clipboard "c:\users\$env:USERNAME\OneDrive - Khan Sports and Entertainment Group\Desktop"
    Start $env:USERPROFILE
}
else
{
    Read-Host 'Onedrive\Desktop folder Already Exists. Press enter to exit' | Out-Null
}