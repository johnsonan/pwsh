$PCWhitelist = @("ELECTGODD-123", "ELECTGODD-123B", "EITSA977PBM2")
$UserFolders = Get-WmiObject -Class Win32_UserProfile -Filter "special=false AND loaded=false" | select -ExpandProperty LocalPath

if ($env:COMPUTERNAME -in $PCWhitelist) {

    $False

}
else { 

    if ($UserFolders) {

        $True

    }
    else {

        $False

    }
}