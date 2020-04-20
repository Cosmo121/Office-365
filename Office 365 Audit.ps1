# Connect to AD
Import-Module ActiveDirectory

function Find-User {
    <#
    .SYNOPSIS
    Checks Active Directory for the specified username. If it exists, return true; if not, return false
    
    .PARAMETER user
    The username specified by the user, using Read-Host

    .EXAMPLE
    Get-Help -user 'username'

    .OUTPUTS
    Outputs a boolean value based on results of AD check
    #>
    param(
        [string]$user  # username of the person being checked.
    )
    try {
        Get-ADUser $user | Out-Null
        Write-Output $true
    }
    catch {
        Write-Warning "That user does not exist in Active Directory`n"
        Write-Output $false
    }
} #end of function Find-User

function Get-Subordinates {
    <#
    .SYNOPSIS
    Grabs the usernames from the DirectReports field in AD and returns them for later use
    
    .PARAMETER manager
    The username of the manager, which is grabbed from AD in the Get-UserInfo function
    
    .INPUTS
    Pulls the username of the manager, which is grabbed from AD in the Get-UserInfo function

    .OUTPUTS
    Outputs an array of usernames. These are the direct reports of the manager

    .EXAMPLE
    Get-Subordinates -manager 'username'
    #>
    param( 
        [string]$manager #username of the manager
    )

    $subordinateUsers = Get-ADUser $manager -Properties DirectReports | Select-Object @{Label='SubordinateUsername';Expression={$_.DirectReports -replace '^CN=|,.*$'}}
    Write-Output $subordinateUsers.SubordinateUsername
} #end of function Get-Subordinates

function Send-MigrationStatus {
    <#
    .SYNOPSIS
    Send-MigrationStatus reads the MsExchRemoteRecipientType value to determine whether the user's mailbox is in the Cloud or not
    
    .PARAMETER migrationStatus
    This is the MsExchRemoteRecipientType value, grabbed from AD in the Get-UserInfo function

    .INPUTS
    The migrationStatus variable, pulled from AD in the Get-UserInfo function ()
    
    .OUTPUTS
    Outputs a string based on the migration status of the mailbox ("Mailbox In Cloud", "Mailbox being migrated to cloud", "Mailbox not in Cloud")

    .EXAMPLE
    Send-MigrationStatus -migrationStatus value
    #>
    param(
        $migrationStatus # numeric value of MsExchRemoteRecipientType
    )

    if ([string]$migrationStatus -eq '6') {
        Write-Output "Mailbox in Cloud"
    }
    elseif ([string]$migrationStatus -eq '4') {
        Write-Output "Mailbox being migrated to Cloud"
    }
    else {
        Write-Output "Mailbox not in Cloud"
    }
} # end of fn Send-MigrationStatus

function Send-LicenseName { 
    <#
    .SYNOPSIS
    Send-LicenseName goes through the array of licenses and returns a new array of easier-to-understand license names.
    
    .DESCRIPTION
    All of our O365 licenses start with AAD LIC then a string of other identifiers to discern which license is which. 
    The most common license is 'Office 365 E3 CORE_EMS_ATP'. This license should be applied to the majority of the workforce; however, there are other licenses than can be applied. 
    F1 licenses are online-only and do not include the Office desktop apps. 
    There are also licenses to access other Office products, like Power BI, Project, Visio, etc. These are also searched for. 

    The function uses a switch statement to go through any possible options. If it finds one that matches, it appends a more appropriate, easier to understand name to an array that is returned at the end of the function.

    .INPUTS
    Inputs an array of licenses that is grabbed from AD in the Get-UserInfo function (licenses)

    .OUTPUTS
    Outputs the array of license names, easier to understand.
    
    .EXAMPLE
    Send-LicenseName -licenses licenseArray
    #>
    param($licenses)

    $arr = @()

    if (!$licenses) {
        $arr += "None"
    }

    else {
        Switch -Wildcard ($licenses) {
            '*Office 365 E3_SPO*' { $arr += "Sharepoint-Only (Vision)" }
            '*Office 365 F1 CORE_EMS_ATP' { $arr += "F1 Core" }
            '*Office 365 E3 EMS_Only*' { $arr += "E3 EMS Only" }
            '*Office 365 E3 CORE_EMS_ATP*' { $arr += "E3 Core" }
            '*Office 365 E3 CORE_PLUS*' { $arr += "E3 Core Plus" }
            '*Office 365 E5 *' { $arr += "E5" }
            '*Power BI Free*' { $arr += "Power BI Free"}
            '*Power BI Pro*' { $arr += "Power BI Pro" }
            '*Project Essentials*' { $arr += "Project Online" }
            '*Project Professional*' { $arr += "Project Professional" }
            '*Project Premium*' { $arr += "Project Premium" }
            '*Visio Online Plan 1*' { $arr += "Visio Online 1" }
            '*Visio Online Plan 2*' { $arr += "Visio Online 2" }
            '*Dynamics 365*' { $arr += "Dynamics 365" }
            '*Windows Defender ATP*' { $arr += "Windows Defender ATP" }
        }
    }

    Write-Output $arr
} #end of fn Send-LicenseName

function Send-SharedMailboxNames {
    <#
        .SYNOPSIS
        Send-SharedMailboxNames gets the proper names of mailboxes based on their Exchange ID (Exchange_####)

        .PARAMETER mailboxIDs
        The Exchange ID for the mailbox

        .INPUTS
        Grabs the Exchange ID from Get-UserInfo
        
        .OUTPUTS
        Outputs a PSCustomObject containing the Mailbox ID and the name

        .EXAMPLE
        Send-SharedMailboxes -mailboxIDs Exchange_1122
    #>
    param($mailboxIDs)

    foreach($m in $mailboxIDs) {
        $mailboxNames = Get-ADGroup $m -Properties Description, Members | Select-Object Description
        $obj = [PSCustomObject]@{
            MailboxID = $m
            MailboxName = $mailboxNames.Description
        }
    }

    if($obj) {
        Write-Output "$user has access to the following shared mailboxes: "
        Write-Output $obj
    }
} # end of fn Send-SharedMailboxNames
function Get-UserInfo {
    <#
        .SYNOPSIS
        Get-UserInfo is the core of this entire script. It grabs all the necessary values from Active Directory, triggers the Send-LicenseName, Send-MigrationStatus, and Send-SharedMailboxNames methods and returns all the audited info as a PSCustomObject

        .DESCRIPTION
        Active Directory stores almost all the necessary information we need. Using the parameter for the username, we run an AD Query to grab the following information: 
        - Username
        - Given Name & Surname
        - Email Address
        - Employee Type (EMP for employee, NCE for contractor)
        - Title (Job title)
        - Enabled (is account active or not)
        - MSExchRemoteRecipientType
        - Manager
        - MemberOf (Necessary for groups)

        It then uses calculated properties to determine the user's full name, the username of the manager, what O365 groups there are (if any), and what shared mailboxes they have access to. 

        Once that's done, it calls the Send-LicenseName, Send-MigrationStatus, and Send-SharedMailboxes methods. 

        Once all the information has been gathered, we create a new PSObject and store all the data inside it. 

        .PARAMETER user
        The username to be searched in AD

        .INPUTS 
        Username to be searched in AD, obtained by Read-Host

        .OUTPUTS
        Outputs a PSCustomObject with all the required user information. 

        .EXAMPLE
        Get-UserInfo -user username
    #>
    param(
        [string] $user # username to be searched 
    )

    $userInfo = Get-ADUser $user -Properties Name, GivenName, Surname, EmailAddress, EmployeeType, Title, Enabled, MsExchRemoteRecipientType, Manager, MemberOf | Select-Object Name, GivenName, Surname, EmailAddress, Title, Enabled, EmployeeType, MsExchRemoteRecipientType, 
        @{
            l="FullName";
            e={
                $_.GivenName + " " + $_.Surname
        }},
        @{
            l="ManagerUsername";
            e={
                $_.Manager -replace "^CN=|,.*$"
            }
        }, 
        @{
            l="O365Groups";
            e={
                $_.MemberOf -like "*AAD LIC*" -replace "^CN=|,.*$"
            }
        }, 
        @{
            l="SharedMailboxes";
            e={
                $_.MemberOf -like "*Exchange_*" -replace "^CN=|,.*$"
            }
        }
    $licenses = Send-LicenseName -licenses $userInfo.O365Groups

    $migrationStatus = Send-MigrationStatus -migrationStatus $userInfo.MsExchRemoteRecipientType

    $sharedMailboxes = Send-SharedMailboxNames -mailboxIDs $userInfo.SharedMailboxes
    
    if (!$userInfo.ManagerUsername) {
        $manager = $false
    }
    else {
        $manager = $userInfo.ManagerUsername
        $subordinates = Get-Subordinates -manager $manager
    }
    
    $output = [PSCustomObject]@{
        Name = $userInfo.Name
        FullName = $userInfo.FullName
        EmployeeType = $userInfo.EmployeeType
        licenses = $licenses
        EmailAddress = $userInfo.EmailAddress
        Title = $userInfo.Title
        Enabled = $userInfo.Enabled
        MigrationStatus = $migrationStatus
        SharedMailboxes = $sharedMailboxes
        Manager = $manager
        Subordinates = $subordinates
    }
    
    Write-Output $output
} # end of fn Get-UserInfo

#Script starts
do {
    do { 
        $user = Read-Host "Please enter the username you would like to check"   #Get the user input (this is the username we want to audit)

        if ($user -ne "") { #Check to make sure the username is not null
            $checkValid = Find-User -user $user #Check to make sure the username is in AD
            if ($checkValid) {
                #Start outputting user data
                Write-Host "`nUser Info:" -ForegroundColor Cyan

                $userInfo = Get-UserInfo -user $user

                $userInfo | Format-Table Name, FullName, EmailAddress, licenses, MigrationStatus, Title, Enabled, EmployeeType -AutoSize

                #Check user's shared mailboxes
                if (!$userInfo.SharedMailboxes) {
                    Write-Warning "User has no shared mailboxes`n"
                }
                else {
                    Write-Host "Shared Mailboxes:`n" -ForegroundColor Cyan
                    $userInfo.SharedMailboxes | Format-Table MailboxID, MailboxName
                }

                #Some employees do not have a manager specified in AD (rare but it happens).
                if ($userInfo.Manager) {    # If there IS a manager, get the manager's information and output as a table (same format as user licenses)
                    Write-Host "Manager Info:" -ForegroundColor Cyan
            
                    $managerInfo = Get-UserInfo -user $userInfo.Manager
                    $managerInfo | Format-Table Name, FullName, EmailAddress, licenses, MigrationStatus, Title, Enabled, EmployeeType -AutoSize

                    #Check the subordinates of the manager
                    Write-Host "Getting subordinate info. Please wait, this can take a while." -ForegroundColor Yellow
                    $subordinateInfo = @()
                    if($userInfo.Subordinates) {
                        foreach($s in $userInfo.Subordinates) {
                            $subordinateInfo += Get-UserInfo -user $s
                        }
                    }
                    Write-Host "`nSubordinate Info:" -ForegroundColor Cyan
                    $subordinateInfo | Format-Table Name, FullName, EmailAddress, licenses, MigrationStatus, Title, Enabled, EmployeeType -AutoSize
                } #end if usersmanager not false

                else {
                    Write-Warning "User has no manager in Active Directory`n"
                }
            } # end if checkValid
        } #end if user not null
        else {
            Write-Warning "Username cannot be null`n"
        }
    } until ($user -ne "" -and $checkValid)
    $doAgain = Read-Host "`nWould you like to run again? Y/N" # Full script loop trigger
} until ($doAgain -eq "N")
