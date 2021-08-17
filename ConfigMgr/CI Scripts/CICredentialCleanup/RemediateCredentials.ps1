$UserProfiles = (Get-ChildItem -Path "C:\Users") | Where Name -ne "Public|Default" | Select -ExpandProperty Name

$Flags = ForEach ($User in $UserProfiles) {

    $PathStub = "C:\Users\$User\AppData"
    $Local    = "Local\Microsoft\Credentials"
    $Roaming  = "Roaming\Microsoft\Credentials"
    
    if (Test-Path "$PathStub\$Local") {
        
        Remove-Item "$PathStub\$Local" -Recurse -Force
        
    }

    if (Test-Path "$PathStub\$Roaming") {
    
        Remove-Item "$PathStub\$Roaming" -Recurse -Force
    
    }  
}
