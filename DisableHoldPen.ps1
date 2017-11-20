## The Purpose of this script is to disable hold down pen for Right Click ##

$H = Get-ItemPropertyValue -Path hkcu:\Software\Microsoft\Wisp\Pen\SysEventParameters -Name HoldMode
if ($H -eq 3)
{
    Write-Host 'Hold for right click Already Disabled'
}
else
{
    Set-ItemProperty -Path hkcu:\Software\Microsoft\Wisp\Pen\SysEventParameters -Name HoldMode -Value 3
    $H = Get-ItemPropertyValue -Path hkcu:\Software\Microsoft\Wisp\Pen\SysEventParameters -Name HoldMode

if ($h -eq 3)
{
  Write-Host 'Hold Pen for Right Click Disabled Succesfully'  
}
else
{
    Write-Host 'Unable to Apply Setting'
}

}
#Read-Host 'Press Enter to continue…' | Out-Null