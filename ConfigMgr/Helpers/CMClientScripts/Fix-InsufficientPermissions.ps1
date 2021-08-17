# Find and remove any SyncML entries under Enrollments key
$Enrollments = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Enrollments\*"
$Paths = $Enrollments | ? ProviderID -match "SyncML" | Select -ExpandProperty PSPath
$Paths | %{ Remove-Item -Path $_ -Force -Recurse}

# Reset CM Agent
&WMIC /Namespace:\\root\ccm path SMS_Client CALL ResetPolicy 1 /NOINTERACTIVE