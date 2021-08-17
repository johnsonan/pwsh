$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Enum"
$DiskPath = Get-Disk | Select -ExpandProperty Path

if($DiskPath.Count -lt 2){

    $DiskType = $DiskPath.Split([char]0x003F, [char]0x0023)
    $RegPath += ($DiskType[1..3] -join "\") + "\Device Parameters\Disk"

    if(!(Test-path $RegPath)){

        New-Item -Path $RegPath -Force

    }

    New-ItemProperty -Path $RegPath -Name "CacheIsPowerProtected" -Value 0 -Type DWORD -Force -Confirm:$False | Out-Null
    New-ItemProperty -Path $RegPath -Name "UserWriteCacheSetting" -Value 0 -Type DWORD -Force -Confirm:$False | Out-Null

}