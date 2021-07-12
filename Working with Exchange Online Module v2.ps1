https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps#install-the-exo-v2-module
<####################################################################
#####################################################################
#####################################################################
##Connecting to Exchange Online Using Exchange Online Powershell V2##
#####################################################################
#####################################################################
####################################################################>


########################## Pre-reqs #################################

# First (requires elevated PS)
Install-Module PowershellGet -Force


# Check to see if you have the EOM Module installed already
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement

# If yes, update it
Update-Module -Name ExchangeOnlineManagement

# If no, install it (requires elevated PS)
Install-Module -Name ExchangeOnlineManagement

# Confirm Installed
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement



############################ Connect ################################

# Use your ADM creds
$UserCredential = Get-Credential

# Connect to EO
Connect-ExchangeOnline -Credential $UserCredential -ShowProgress $true



############################ Do Things ################################

# Get info about a group or distro
Get-Recipient -Identity "Marketing Department" | Format-List

# Get info about a user
Get-User -Identity "Mike Hartman" | Format-List

# Add a user to a distro/group
Add-DistributionGroupMember -Identity "all-office" -Member "userName@contoso.com"

# Returns the values of client access settings
Get-EXOCASMailbox -Identity "mailboxName@contoso.com"

Get-EXOMailboxStatistics -Identity userName@contoso.com -Properties DisplayName,DeletedItemCount,ItemCount,TotalDeletedItemSize,TotalItemSize
# see https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/exchange-online-powershell-v2/cmdlet-property-sets?view=exchange-ps#get-exomailbox-property-sets

############################ Dynamic Distros ###########################

# List all dynamic distros
Get-DynamicDistributionGroup

# Get info about a specific dynamic distro
Get-DynamicDistributionGroup -Identity "all-office" | Format-List

# list all members of a dynamic distro
$FTE = Get-DynamicDistributionGroup "all-office"; Get-Recipient -RecipientPreviewFilter $FTE.RecipientFilter -OrganizationalUnit $FTE.RecipientContainer
