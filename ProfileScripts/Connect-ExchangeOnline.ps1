Function Connect-ExchangeOnline ($Prefix) {
    $Connected = Get-PSSession | Where-Object {$_.Name -match "ExchangeOnlineInternalSession"}

    if (!$Connected) {

        if ($Prefix) {
            ExchangeOnlineManagement\Connect-ExchangeOnline -Prefix $Prefix
        } else {
            ExchangeOnlineManagement\Connect-ExchangeOnline
        }
    }
}