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


############################ Microsoft 365 Groups ################################

# Get info about M365 Group
Get-UnifiedGroup -Identity "Legal Department" | Format-List

# Add member(s)
Add-UnifiedGroupLinks -Identity "Legal Department" -LinkType Members -Links chris@contoso.com,michelle@contoso.com -confirm

# Add owner(s)
Add-UnifiedGroupLinks -Identity "Legal Department" -LinkType Owners -Links chris@contoso.com,michelle@contoso.com -confirm

# Remove member(s)
Remove-UnifiedGroupLinks -Identity "People Leaders" -LinkType Members -Links laura@contoso.com,julia@contoso.com -confirm

# Remove owner(s)
Remove-UnifiedGroupLinks -Identity "People Leaders" -LinkType Owners -Links laura@contoso.com,julia@contoso.com -confirm

# Create new
New-UnifiedGroup -accesstype Private -AutoSubscribeNewMembers -DisplayName "Group Name" -EmailAddresses groupname@contoso.com -Owner julia@contoso.com -Members chris@contoso.com,michelle@contoso.com -notes "Requested by Susan Suzzy"

# Add authorized sender(s)
Set-UnifiedGroup -Identity  "Group Name" -AcceptMessagesOnlyFrom @{add="email@contoso.com"} -confirm

# Auto subscribe new members
Set-UnifiedGroup -Identity  "Group Name" -AutoSubscribeNewMembers:$true

# Hide from GAL
Set-UnifiedGroup -Identity  "Group Name" -HiddenFromAddressListsEnabled:$true

############################ Documentation ################################
<#
Get-UnifiedGroup: https://docs.microsoft.com/en-us/powershell/module/exchange/get-unifiedgroup
Add-UnifiedGroupLinks: https://docs.microsoft.com/en-us/powershell/module/exchange/add-unifiedgrouplinks
Remove-UnifiedGroupLinks: https://docs.microsoft.com/en-us/powershell/module/exchange/remove-unifiedgrouplinks
New-UnifiedGroup: https://docs.microsoft.com/en-us/powershell/module/exchange/new-unifiedgroup
Set-UnifiedGroup: https://docs.microsoft.com/en-us/powershell/module/exchange/set-unifiedgroup
#>
