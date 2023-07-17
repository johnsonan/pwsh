# See here for more information: https://community.spiceworks.com/topic/2322727-exchange-hybrid-quickly-and-reliably-create-shared-mailboxes

Function New-SharedMailbox {
    [CmdletBinding()]
    param (
        # Name of mailbox
        # e.g. "Andrew Johnson (Dept)"
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $FullName,

        # The alias, by convention the left-hand portion of the email address
        # e.g. 'johnsonan' is the alias for 'johnsonan@easternct.edu'
        # This will determine the email address.
        [string]
        $Alias,

        # Organizational unit for on-prem AD record, generally the department requesting the mailbox.
        [string]
        $OU,

        # A list of members as mail aliases (see above for description of an alias)
        [Parameter(
            Mandatory = $false
        )]
        [string[]]
        $Members
    )

    # Import helper function for ExOnPrem and AAD Sync
    ."$PSScriptRoot\Connect-ExchangeOnPrem.ps1"
    ."$PSScriptRoot\Start-AADDeltaSync.ps1"

    # Connect to necessary Exchange services
    Write-Verbose "Connecting to Exchange Online and On-Prem..."
    Connect-ExchangeOnline -Prefix "OL"
    Connect-ExchangeOnPrem -Prefix "OP"

    # Create on-prem remote mailbox record
    Write-Verbose "Creating on-prem mailbox..."
    New-OPRemoteMailbox -DisplayName $FullName -UserPrincipalName "$Alias@easternct.edu" -OnPremisesOrganizationalUnit $OU -RemoteRoutingAddress "$Alias@myeasternct.mail.onmicrosoft.com" -Name $FullName -Shared
    Write-Verbose "Waiting 10 seconds for directory replication..."
    Start-Sleep -Seconds 10

    # Start delta sync and wait
    Write-Verbose "Starting Azure AD Sync..."
    Start-AADDeltaSync | Out-Null
    Write-Verbose "Waiting for mailbox to appear in Azure. This may take some minutes to complete..."
    while (!(Get-OLMailbox -Identity $FullName)) {
        Start-Sleep -Seconds 10
    }
    
    # Set permissions for all members in cloud and on prem
    Write-Verbose "Adding mailbox permissions online and on-prem..."
    Foreach ($Member in $Members) {
        try {
            Add-OLMailboxPermission "$FullName" -User $Member -AccessRights FullAccess -InheritanceType All -ea Stop
            Add-OLRecipientPermission "$FullName" -Trustee $Member -AccessRights SendAs -Confirm:$false -ea Stop
            Add-OPADPermission -Identity "$FullName" -User $Member -AccessRights ExtendedRight -ExtendedRights "Send As" -ea Stop
        } catch {
            Write-Error "An error occurred for account $Member`:`n$_"
        }
    }
}