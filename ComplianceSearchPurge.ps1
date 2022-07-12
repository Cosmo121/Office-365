<#
Use Modern Auth to connect to Security and Compliance
#>

# Pre-req for EXO V2; Make sure it is installed
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser

Import-Module ExchangeOnlineManagement

Connect-IPPSSession -UserPrincipalName user@domain.com

# Run a Search Action to Purge Emails
New-ComplianceSearchAction -SearchName "$SearchName" -Purge -PurgeType SoftDelete

# Check on the status of Purge
Get-ComplianceSearchAction -Identity "$SearchName" | Format-List
