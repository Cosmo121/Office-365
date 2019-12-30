# Store credentials
$LiveCred = Get-Credential

# Connect to 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionURI https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection

# user1 is placeholder for the user with calendar
# View current permissions on user calendar
Get-MailboxFolderPermission user1:\calendar

# user2 is placeholder for user you want to have permissions
# Give user permissions
Add-MailboxFolderPermission -Identity user1@avidxchange.com:\calendar -user user2@avidxchange.com -AccessRights Editor

# Set default permission for $user1
Set-MailboxFolderPermission -Identity user1@avidxchange.com:\calendar -User Default -AccessRights Reviewer

# Remove user2 from calendar
Remove-MailboxFolderPermission -Identity user1@avidxchange.com:\calendar -user2@avidxchange.com

# Disconnect
Remove-PSSession $Session
