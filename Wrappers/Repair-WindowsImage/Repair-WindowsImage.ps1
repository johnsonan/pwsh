# Get local Windows version from registry (1809, 1909, etc)
$WinVer = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId).ReleaseId

# Build out WIM path:
# If kept consistent on the share, this should always work
# Currently works for 1703, 1709, 1803, 1809, 1909
$WimPath = "\\some\path\source$\Images\Windows 10 $WinVer\sources\install.wim"

# Start repair process
if (Test-Path $WimPath) {

    $Output = Repair-WindowsImage -Source $WimPath -RestoreHealth -Online -NoRestart

}

# Output results
if ($null -ne $Output) {

    "Status: Success"
    "Image State: $($Output.ImageHealthState)"
    "WIM: $WimPath"
    "Restart Needed: $($Output.RestartNeeded)"

} else {

    "Status: Failed"
    "WIM: $WimPath"

}
