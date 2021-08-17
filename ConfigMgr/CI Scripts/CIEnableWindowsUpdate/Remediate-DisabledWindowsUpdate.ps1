$StartType = Get-Service -Name wuauserv | Select -Expand StartType

if ($StartType -eq $Disabled) {

    $false

} else {

    $true

}