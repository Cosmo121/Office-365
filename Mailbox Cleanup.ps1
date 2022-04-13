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


############################ Mailbox Cleanup ################################

# Simple mailbox check for size
Get-EXOMailboxStatistics -Identity john@contoso.com | Format-Table Name,DeletedItemCount,ItemCount,TotalDeletedItemSize,TotalItemSize

# Another query for mailbox statistics
Get-EXOMailboxFolderStatistics mailboxname@contoso.com -FolderScope RecoverableItems | Format-Table Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders

# Check mailbox retention for deleted items
Get-EXOMailbox mailboxName@contoso.com | Format-Table RetainDeletedItemsFor
# Set the mailbox retention
Set-Mailbox mailboxName@contoso.com -RetainDeletedItemsFor 30

# Check ELC status
Get-EXOMailbox mailboxName@contoso.com | Format-Table ElcProcessingDisabled
# Set ELC
Set-Mailbox mailboxName@contoso.com -ElcProcessingDisabled $true


# Clean out mailbox by searching for a phrase with a wildcard
$mbx = Get-EXOMailbox mailboxName@contoso.com;
Do {
$result = Search-Mailbox -Identity $mbx.Identity -SearchQuery 'subject:"Phrase with wildcard*"' -DeleteContent -force -WarningAction Silentlycontinue;
$result | Out-file c:\temp\mailsearch.log -append;
write-Host "Search result for username: " + $result.resultitemscount -ForegroundColor Green;
} Until ($result.resultitemscount -eq 0)

# Clean out mailbox by searching for items from a particular sender, AND a date
$inputbox = "mailboxName"
$mbx = Get-EXOMailbox $inputbox;
Do {
$result = Search-Mailbox -Identity $mbx.Identity -SearchQuery 'from:"someone@contoso.com" AND received:"02/20/2020"' -deletecontent -force -WarningAction Silentlycontinue;
write-Host "Search result for " $inputbox ": " + $result.resultitemscount -ForegroundColor Green;
 } Until ($result.resultitemscount -eq 0)


############################ Documentation ################################
<#
Get-EXOMailboxStatistics: https://docs.microsoft.com/en-us/powershell/module/exchange/get-exomailboxstatistics
Get-EXOMailboxFolderStatistics: https://docs.microsoft.com/en-us/powershell/module/exchange/get-exomailboxfolderstatistics
Search-Mailbox: https://docs.microsoft.com/en-us/powershell/module/exchange/search-mailbox
Get-EXOMailbox: https://docs.microsoft.com/en-us/powershell/module/exchange/get-exomailbox
Set-Mailbox: https://docs.microsoft.com/en-us/powershell/module/exchange/set-mailbox
#>
