https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps#install-the-exo-v2-module
<####################################################################
#####################################################################
#####################################################################
##Connecting to Exchange Online Using Exchange Online Powershell V2##
#####################################################################
#####################################################################
####################################################################>


########################## Pre-reqs #################################

# Check to see if you have the EOM Module installed already
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement

# If yes, update it
Update-Module -Name ExchangeOnlineManagement -Scope CurrentUser

# If no, install it (requires elevated PS)
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser

# Confirm Installed
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement

############################ Connect ################################

# Connect to EO
Connect-ExchangeOnline -UserPrincipalName username@domain.com -ShowProgress $true
