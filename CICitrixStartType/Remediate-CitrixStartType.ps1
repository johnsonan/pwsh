# Get all Citrix Services
$CitrixSvcs = Get-Service -DisplayName "Citrix*" | Select -ExpandProperty Name

# Set start_type to delayed-auto for all
$SvcDetails = $CitrixSvcs | %{ &sc.exe config $_ start= delayed-auto }
