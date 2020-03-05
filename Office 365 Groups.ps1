<#
https://docs.microsoft.com/en-us/powershell/module/exchange/users-and-groups/get-unifiedgroup?view=exchange-ps
#>

# add members to a 365 group
Add-UnifiedGroupLinks -Identity "People Leaders" -LinkType Members -Links chris@contoso.com,michelle@contoso.com -confirm

# add owners to a 365 group
Add-UnifiedGroupLinks -Identity "People Leaders" -LinkType Owners -Links chris@contoso.com,michelle@contoso.com -confirm



# remove members of a 365 group
Remove-UnifiedGroupLinks -Identity "People Leaders" -LinkType Members -Links laura@contoso.com,julia@contoso.com -confirm

# remove owners of a 365 group
Remove-UnifiedGroupLinks -Identity "People Leaders" -LinkType Owners -Links laura@contoso.com,julia@contoso.com -confirm



# get info about a particular 365 group
Get-UnifiedGroup -Identity "People Leaders" | Format-List



# create new 365 group
New-UnifiedGroup -accesstype Private -AutoSubscribeNewMembers -DisplayName "Group Name" -EmailAddresses groupname@contoso.com -Owner julia@contoso.com -Members chris@contoso.com,michelle@contoso.com -notes "Requested by Susan Suzzy"


# add authorized sender(s)
Set-UnifiedGroup -Identity  "Group Name" -AcceptMessagesOnlyFrom @{add="email@contoso.com"} -confirm


# check for stuff:
Get-UnifiedGroup -Identity "Group Name" | Format-List acceptmessagesonlyfrom

Get-UnifiedGroup -Identity "Group Name" | Format-List mangedby
