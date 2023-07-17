Function Get-UserCalendarInfo {
    [CmdletBinding()]
    param (
        # Recipient UPN
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $Identity
    )

    $AllCalendars = Get-MailboxFolderStatistics $Identity | ? ContainerClass -match "IPF.Appointment"

    $Results = ForEach ($Calendar in $AllCalendars) {
        [PSCustomObject]@{
            Name = $Calendar.Name
            Path = $Calendar.Identity
            Permissions = Get-MailboxFolderPermission $($Calendar.Identity.Replace("easternct.edu\", "easternct.edu:\"))
        }
    }

    $Results
}