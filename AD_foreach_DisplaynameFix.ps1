$collection= Get-ADUser -SearchBase "OU=MigratedUsers,OU=Jaguars,DC=Jaguars,DC=net" -Filter *
foreach ($name in $collection)
{
    $F= $name.givenname #First Name
    $L= $name.Surname   #Last name
    $full= "$L, $F"  #setting string to Last, First to set to display name
    set-aduser $name -DisplayName $full
}