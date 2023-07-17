Function Set-HomeDrivePermissions($Path) {
    try {
        $accountName = $User.SamAccountName
        $homeDirectory = $Path
        $dirACL = Get-Acl $homeDirectory -ea "Stop"
        $dirACL.GetAccessRules($true, $true, [System.Security.Principal.NTAccount])
        $dirACL.SetAccessRuleProtection($True, $False)
        $dirACE = New-Object System.Security.AccessControl.FileSystemAccessRule ($accountName,"FullControl","ContainerInherit, ObjectInherit", "None", "Allow") -ea "Stop"
        $dirACL.AddAccessRule($dirACE)
        $dirACL.SetAccessRule($dirACE)
        Set-Acl $homeDirectory $dirACL -ea "Stop"

        $dirACE_EA = New-Object System.Security.AccessControl.FileSystemAccessRule ("Enterprise Admins","FullControl","None", "None", "Allow") -ea "Stop"
        $dirACL.AddAccessRule($dirACE_EA)
        Set-Acl $homeDirectory $dirACL -ea "Stop"
    } catch {
        Write-Error "Could not assign permissions. Exiting."
    }
}

Function Create-HomeDrive($Username) {

    Import-Module ActiveDirectory
    $User = Get-ADUser -Identity $Username -Properties "homeDirectory"

    if ($User.homeDirectory -notmatch $User.samAccountName) {
        # Make sure homeDirectory isn't parent directory, this happens sometimes
        $homeDirectory = $User.homeDirectory + "\$($User.SamAccountName)"
    } else {
        $homeDirectory = $User.homeDirectory
    }

    # Make sure directory doesn't exist
    if (!(Test-Path $homeDirectory)) {
        if ($homeDirectory -notmatch $User.samAccountName) {
            # Make sure homeDirectory isn't parent directory, this happens sometimes
            Write-Error "Home directory path is malformed and does not contain the user's samAccountName. Exiting."
        } else {

            # Create directory
            # Make sure we successfully create the folder before continuing
            try {
                New-Item -Path "$($homeDirectory)" -ItemType "Directory" -ea "Stop"
            } catch {
                Write-Error "Could not create directory at $($homeDirectory). Exiting."
            }
            
            # Assign permissions
            Set-HomeDrivePermissions -Path $homeDirectory
        }
    } else {
        Write-Error "Home directory already exists at $($homeDirectory). Exiting."
        exit 1
    }
}