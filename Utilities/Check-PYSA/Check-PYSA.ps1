[CmdletBinding()]

$FoundFile = $false
$Users     = Get-ChildItem -Path "C:\Users" -Directory | Select -ExpandProperty Name

ForEach ($User in $Users) {

    if (Test-Path "C:\Users\$User\Downloads\svchost.exe") {

        $FoundFile = $true
        break

    }

}

return $FoundFile