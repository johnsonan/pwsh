Function Get-ADUserByFullName ($FullName) {

    # Assuming $FullName is formatted as $First $Last
    # First, format inputs into first and last
    $First, $Last = ($FullName -split "\s").Trim().Replace("’", "'")

    # Handle middle initials and double last names
    if ($Last.Count -gt 1) {
        #if(($Last[0] -replace "\W").Length -eq 1) {
        #    $Last = $Last[1]
        #} else {
        #    $Last = $Last -join " "
        #}
        $Last = $Last[1]
    }

    # Try and find AD user using first and last properties
    try {
        $ADUser = Get-ADUser -Filter {givenName -eq $First -and sn -eq $Last} 
        if (!$ADUser.Count -and $ADUser) {
            return $ADUser
        }
    } catch {
        Write-Warning "Malformed first and last name for $FullName"
    }


    # Try and find AD user by building username one character at a time
    $First = $First -replace "\W", ""
    $Last = $Last -replace "\W", ""
    $Cursor = 0
    $SamAccountName = ($Last + $First[0..$Cursor]).Trim() + "*"
    try {
        $ADUser = Get-ADUser -Filter {samAccountName -like $SamAccountName} 

        while ($ADUser.Count -gt 1) {
            $Cursor++
            $FirstFragment = $First[0..$Cursor] -join ""
            $SamAccountName = ($Last + $FirstFragment).Trim() + "*"
            $ADUser = Get-ADUser -Filter {samAccountName -like $SamAccountName} 
        }
    } catch {
        Write-Warning "No account found for $FullName, retrying..."
    }

    if ($ADUser) {
        return $ADUser
    } else {
        Write-Warning "Unable to find AD user for $FullName`nLast attempt: $SamAccountName"
    }
}