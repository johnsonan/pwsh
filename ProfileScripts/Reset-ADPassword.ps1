Function Reset-ADPassword {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $Identity,

        # Generates random base64 password instead of default
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $Random
    )

    $User = Get-ADUser -Identity $Identity -Properties "employeeId"

    if ($Random) {
        Add-Type -AssemblyName 'System.Web'
        $PasswordString = [System.Web.Security.Membership]::GeneratePassword(13, 2)
    } else { 
        #Omitted
    }

    $Password = ConvertTo-SecureString $PasswordString -AsPlainText -Force

    try {
        Set-ADAccountPassword -Identity $Identity -NewPassword $Password -Reset
    } catch {
        throw "Failed to set password for $($User.Name)."
    }
    
    "Password for $($User.Name) reset to $PasswordString"
}