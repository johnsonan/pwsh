$AMDFirePro = Get-PnpDevice -FriendlyName "AMD FirePro W2100*"

if ($AMDFirePro.Status -eq "OK") {

    $false

} else {

    $true

}