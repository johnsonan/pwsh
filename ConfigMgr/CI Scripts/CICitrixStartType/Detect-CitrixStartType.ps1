# Get all Citrix Services
$CitrixSvcs = Get-Service -DisplayName "Citrix*" | Select -ExpandProperty Name

# Query services with sc.exe
# Powershell nor WMI expose the "Automatic (Delayed)" StartType
$SvcDetails = $CitrixSvcs | %{ &sc.exe qc $_ }

# Format CLI output to show only Start_Types
$RawStartType = $SvcDetails | ? {$_ -match "START_TYPE"}
$SvcStartType = $($RawStartType | %{ $($_ -split ":")[-1] }).Replace(" 2   ", "")

# If ANY "AUTO_START" exists, then false
# meaning they should ALL be delayed
$Flags = $SvcStartType.ForEach({

    if ($_ -eq "AUTO_START") {

        $false
  
    } else {

        $true

    }

})

if ($Flags -contains $false) {

    $false

} else {

    $true

}
