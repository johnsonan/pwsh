# Initialize directories
$UsersDir = "C:\Users"
$CredDir  = "AppData\Local\Microsoft\Credentials"
$LicDir   = "AppData\Local\Microsoft\Office\16.0\Licensing"

# Get $UsersDir subfolders
$UserFolders = Get-ChildItem -Path $UsersDir -Directory -Exclude "Default", "Public"

# Pull out fullnames
$UserFolders = $UserFolders.FullName

# Loop through folders, delete Credentials and Licensing folders
ForEach ($Folder in $UserFolders) {

    if (Test-Path "$Folder\$CredDir") {

        Remove-Item -Path "$Folder\$CredDir" -Recurse -Force

    }

    if (Test-Path "$Folder\$LicDir") {

        Remove-Item -Path "$Folder\$LicDir" -Recurse -Force

    }

}

# Run OLicenseCleanup script
Start-PRocess -FilePath .\cscript.exe -ArgumentList "\\some\path\to\OLicenseCleanup.vbs" -WindowStyle Hidden
