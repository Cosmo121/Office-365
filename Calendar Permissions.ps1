########################## Pre-reqs #################################

# Check to see if you have the EOM Module installed already
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement

# If yes, update it
Update-Module -Name ExchangeOnlineManagement -Scope CurrentUser

# If no, install it
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser

# Confirm Installed
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement


############################ Connect ################################

# Connect to EO
Connect-ExchangeOnline -UserPrincipalName user@domain.com -ShowProgress $true


############################ Manage Calendar Permissions ################################

# View current permissions for user's calendar
Get-MailboxFolderPermission -Identity user@domain.com:\Calendar | ft Identity,FolderName,User,AccessRights,SharingPermissionFlags

# Set user to have Editor permissions to user's calendar | Note that Delegate will be able to do everything except view private events
# | Note that -SendNotificationToUser is true and the person will get an email to accept the permissions
Set-MailboxFolderPermission -Identity user@domain.com:\Calendar -User user@domain.com -AccessRights Editor -SharingPermissionFlags Delegate -SendNotificationToUser $true

# Remove permissions
Remove-MailboxFolderPermission -Identity user@domain.com:\Calendar -User user@domain.com


############################ Documentation ################################

<#
Setting up EXO V2: https://docs.microsoft.com/en-us/powershell/exchange/connect-to-exchange-online-powershell
Get-MailboxFolderPermissions: https://docs.microsoft.com/en-us/powershell/module/exchange/get-mailboxfolderpermission
#>
