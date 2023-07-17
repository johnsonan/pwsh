Function Update-IPPhone ($SamAccountName, $Phone) {
    if ($Phone) {
        $Phone = "+1" + $Phone.Trim() -replace "\(|\)|\s|-", ""
    }
    
    if ($Phone.Length -ne 12 -and $Phone.Length -ne 0) {
        throw "Error in DID length $Phone for user $SamAccountName"
    } elseif ($Phone.Length -eq 0) {
        Write-Warning "Clearing ipPhone attribute for $SamAccountName" -WarningAction Inquire
    } else {
        Set-ADUser -Identity $SamAccountName.Trim() -Replace @{'ipPhone' = $Phone}
    }
}