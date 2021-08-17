Param(

    [Parameter(
        Mandatory = $true
    )]
    [string]
    $EntryName,

    [Parameter(
        Mandatory = $true
    )]
    [string]
    $CommandLine,

    [Parameter(
        Mandatory = $false
    )]
    [string]
    $RunOnce = "False"

)

if ($RunOnce -eq "True") {

    $KeyPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"

} else {

    $KeyPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"

}

New-ItemProperty -Path $KeyPath -Name $EntryName -PropertyType String -Value $CommandLine -Force