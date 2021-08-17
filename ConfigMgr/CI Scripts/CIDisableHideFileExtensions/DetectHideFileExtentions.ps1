# Load default user hive       

&REG LOAD "HKLM\DefaultUser" "C:\Users\Default\NTUSER.DAT" | Out-Null

if (!(Test-Path "HKLM:\DefaultUser")) {

    throw "Unable to load default user registry hive from C:\Users\Default\NTUSER.DAT into HKLM\DefaultUser."

} else {

    Write-Verbose "Default user registry hive loaded into HKLM\DefaultUser from C:\Users\Default\NTUSER.DAT"

}

# Disable Hide File Extention

$path = "HKLM:\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

$value = (Get-ItemProperty -Path $path -Name HideFileExt -EA SilentlyContinue).HideFileExt

if ($value -eq 0) {
    
    $true
         
} else {
    
    $false
}

# Unload default user hive

if (Test-Path "HKLM:\DefaultUser") {

    # Invoke garbage collector, otherwise unload fails due to lock
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()

    &REG UNLOAD "HKLM\DefaultUser" > null 2>&1

    if (Test-Path "HKLM:\DefaultUser") {

        throw "Unable to unload default user registry hive from HKLM\DefaultUser."

    } else {

        Write-Verbose "Successfully unloaded default user registry hive from HKLM\DefaultUser."

    }

}