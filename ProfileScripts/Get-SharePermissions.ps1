Function Get-SharePermission ([string]$Path) {
    $Match = ($Path | Select-String -Pattern "\\?\\?\w+-\w+\\?").Matches.Value
    $Server = $Match.Replace("\", "")
    $Share = $Path.Replace($Match, "").Replace("\", "")

    try {
        $Session = New-CimSession -ComputerName $Server -ea Stop
    } catch {
        Write-Warning "Session creation failed for $Server - checking DNS aliases."
        $Alias = (Resolve-DNSName $Server)[0] | Select -Expand NameHost

        if ($Alias) {
            Write-Warning "Alias found, trying $Alias..."
            $Server = $Alias
            $Session = New-CimSession -ComputerName $Server
        }
    }
    
    Get-SmbShareAccess -Name $Share -CimSession $Session

    $Session | Remove-CimSession
} 