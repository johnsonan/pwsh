Function Connect-ExchangeOnPrem {

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $Prefix,

        [Parameter(
            Mandatory = $true
        )]
        [string]
        $ExchangeServer
    )

    $Connected = Get-PSSession | Where-Object {$_.Name -match "WinRM" -and $_.ConfigurationName -eq "Microsoft.Exchange"}

    if (!$Connected) {
        $Session = New-PSSession -Configurationname Microsoft.Exchange -ConnectionUri http://$ExchangeServer/powershell

        if ($Prefix) {
            Import-PSSession $Session -Prefix $Prefix
        } else {
            Import-PSSession $Session
        }
    }
}
