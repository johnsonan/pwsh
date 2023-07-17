Function Add-SharedMailboxMember {
    [CmdletBinding()]
    param (
        # User Upn
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $MemberUpn,

        # Shared Mailbox Upn
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $MailboxUpn
    )

    # Import Exchange Online (OL) and On-prem (OP)
    ."$PSScriptRoot\Connect-ExchangeOnPrem.ps1"
    ."$PSScriptRoot\Connect-ExchangeOnline.ps1"
    Connect-ExchangeOnline -Prefix "OL"
    Connect-ExchangeOnPrem -Prefix "OP"

    # Get user and mailbox information
    # A bit tricky due to differences between Exchange Online and On-prem attributes
    $MailboxAdUser = Get-ADUser -Filter {mail -eq $MailboxUpn} -Properties "legacyExchangeDN", "distinguishedName"
    $Member        = Get-ADUser -Filter {UserPrincipalName -eq $MemberUpn} | Select-Object -Expand SamAccountName
    $MailboxExchDn = $MailboxAdUser.legacyExchangeDN
    $MailboxAdDn   = $MailboxAdUser.distinguishedName

    # Add mailbox permissions for on-prem and online mailbox
    try {
        Add-OLMailboxPermission "$MailboxExchDn" -User $Member -AccessRights FullAccess -InheritanceType All -ea Stop
        Add-OLRecipientPermission "$MailboxExchDn" -Trustee $Member -AccessRights SendAs -Confirm:$false -ea Stop
        Add-OPADPermission -Identity "$MailboxAdDn" -User $Member -AccessRights ExtendedRight -ExtendedRights "Send As" -ea Stop
    } catch {
        Write-Error "An error occurred for account $Member`:`n$_"
    }
}