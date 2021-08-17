$ODThreshold = Get-Item "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive\DiskSpaceCheckThresholdMB"

if($ODThreshold){
    $True
} else { $False }