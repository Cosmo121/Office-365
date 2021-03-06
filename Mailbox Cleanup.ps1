$LiveCred = get-credential

# Connect to Exchange
$session = new-pssession -configurationname microsoft.exchange -connectionuri https://ps.outlook.com/powershell -credential $LiveCred -authentication basic -allowredirection

import-pssession $session

# Simple mailbox statistic check for size
Get-MailboxStatistics mailboxname@contoso.com | Format-List Name,DeletedItemCount,ItemCount,TotalDeletedItemSize,TotalItemSize

# Another query for mailbox statistics
Get-MailboxFolderStatistics mailboxname@contoso.com -FolderScope RecoverableItems | FL Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders

# Check mailbox retention for deleted items
Get-Mailbox mailboxName | Format-List RetainDeletedItemsFor
# Set the mailbox retention
Set-Mailbox mailboxName -RetainDeletedItemsFor 30


# Check ELC status
Get-Mailbox mailboxName | Format-List ElcProcessingDisabled
# Set ELC
Set-Mailbox mailboxName -ElcProcessingDisabled $true



# Clean out mailbox by searching for a phrase with a wildcard
$mbx = get-mailbox mailboxname@contoso.com;
Do {
$result = Search-Mailbox -Identity $mbx.Identity -SearchQuery 'subject:"Phrase with wildcard*"' -DeleteContent -force -WarningAction Silentlycontinue;
$result | Out-file c:\temp\mailsearch.log -append;
write-Host "Search result for username: " + $result.resultitemscount -ForegroundColor Green;
} Until ($result.resultitemscount -eq 0)

# Clean out mailbox by searching for items from a particular sender, AND a date
$inputbox = "mailboxName"
$mbx = get-mailbox $inputbox;
Do {
$result = Search-Mailbox -Identity $mbx.Identity -SearchQuery 'from:"someone@contoso.com" AND received:"02/20/2020"' -deletecontent -force -WarningAction Silentlycontinue;
write-Host "Search result for " $inputbox ": " + $result.resultitemscount -ForegroundColor Green;
 } Until ($result.resultitemscount -eq 0)
