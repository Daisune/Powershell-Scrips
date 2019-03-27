# Declaring a Shit ton of variables
$AdminPass = Get-Credential -Message "Admin Account with AD creation rights"
$OG = (Read-Host -Prompt 'Account w/ Memberships Being Copied')
$First = (Read-Host -Prompt 'New User First Name')
$Last = (Read-Host -Prompt 'New User Last Name')
$FI=$First.substring(0,1)   ##Gets first letter of First name
$LI=$Last.substring(0,1)   ##gets first letter of Last name
$FIU =$FI.ToUpper()  #Converts first initial to Upper For PW set
$LIU =$LI.ToUpper()  #Converts last initial to Upper for PW set
$FIL =$FI.ToLower()  #Converts first initial to lower For UserVar set
$LIL =$LI.ToLower()  #Converts last initial to lower for UserVar set
$Temp = "$FIL$Last"
$SAM = $Temp.ToLower()  ## Pre2k Username/Identifier
$Temp = "$Last$FIL"
$Name = $Temp.ToLower()
$PW ='J@g' + $FIU + $LIU + '2019!' #standard new hire PW
# Setting 
$Properties =
 @( 
 'Description',
 'Department',
 'Manager',
 'Organization',
 'Title',
 'homedrive',
 'ScriptPath',
 'MemberOf'
 )
#Gets properties of account being copied
Get-ADUser -Identity $OG -Properties $Properties -OutVariable acctprop  
#Creates new user and applies settings
New-ADUser -Credential $AdminPass -Name $SAM -AccountPassword (ConvertTo-SecureString "$PW" -AsPlainText -Force) -Company Jaguars -Department $acctprop.Department -Description $acctprop.Description -DisplayName "$Last, $First" -EmailAddress $Name@nfl.jaguars.com -GivenName $First -HomeDirectory \\Fileserver1\users\$SAM -HomeDrive H: -Manager $acctprop.Manager -Office Jaguars -SamAccountName $SAM -ScriptPath $acctprop.ScriptPath -Surname $Last -Title $acctprop.Title -UserPrincipalName $Name@nfl.jaguars.com -Enabled 1
#applies Groups/Memberships from OG to New user
Get-ADUser -Identity $OG -Credential $AdminPass -Properties memberof |Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $SAM -Credential $AdminPass
SET-ADUSER $SAM –replace @{msExchExtensionAttribute44=”$name@nfl.jaguars.com”} -Credential $AdminPass
# Creates Folder for new user
Write-Output "Creating H Drive.."
New-Item "\\fileserver1\users\$SAM" -ItemType Directory
Write-Output "Setting Permisssions.."
$acl = Get-Acl \\fileserver1\users\$SAM
$acl.SetAccessRuleProtection($true,$false) #Disable Inheritance and remove inherited permissions
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Jaguars\$SAM","FullControl","Allow")#Sets full access to folder for User
$object = New-Object System.Security.Principal.Ntaccount("Jaguars\$SAM") #sets ownership 
$acl.SetAccessRule($AccessRule) #adds Perm to object
$acl.SetOwner($object)  #adds Owner ACL to Object
$acl | Set-Acl \\fileserver1\users\acltesting  #apples all ACLs to target Folder