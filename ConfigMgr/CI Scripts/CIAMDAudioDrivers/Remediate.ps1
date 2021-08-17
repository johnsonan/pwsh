$AMDHDAudio = Get-PnpDevice -FriendlyName "AMD High Definition Audio Device"
$AMDHDAudioBus = Get-PnpDevice -FriendlyName "High Definition Audio Bus" | Where Manufacturer -match "AMD"

Disable-PnpDevice -InputObject $AMDHDAudio
Disable-PnpDevice -InputObject $AMDHDAudioBus

$AudioWMI = Get-WmiObject Win32_PnPSignedDriver -filter "DeviceName='AMD High Definition Audio Device'"