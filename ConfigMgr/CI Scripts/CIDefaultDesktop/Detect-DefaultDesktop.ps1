$DefaultDestinations = Get-ChildItem -Path "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations"

if ($DefaultDestinations.Count -gt 0) {

    $false

} else {

    $true

}