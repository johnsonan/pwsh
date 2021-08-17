$TCPEnabled = Get-NetAdapterChecksumOffload -Name "*" | ? TcpIPv4Enabled -ne "Disabled"
$IPEnabled  = Get-NetAdapterChecksumOffload -Name "*" | ? IpIPv4Enabled -ne "Disabled"

if ($TCPEnabled -or $IPEnabled) {

    $true

} else {

    $false

}