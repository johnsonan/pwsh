Function New-ExchangeConnection {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $ServerName
    )

    $Session = New-PSSession -ConnectionUri "http://$ServerName/powershell" -ConfigurationName "Microsoft.Exchange"

    Import-PSSession $Session
}