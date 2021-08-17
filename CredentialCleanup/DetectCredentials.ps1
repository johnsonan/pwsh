$UserProfiles = (Get-ChildItem -Path "C:\Users") | Where Name -ne "Public|Default" | Select -ExpandProperty Name

$Flags = ForEach ($User in $UserProfiles) {

    $Vault = "C:\Users\$User\AppData\Local\Microsoft\Vault"
    
    if (Test-Path $Vault) {
        
        $False
        
    } else {
    
        $True
    
    }    
}

if ($False -in $Flags) {

    $False

} else { $True }