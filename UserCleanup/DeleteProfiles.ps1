&taskkill /f /im onedrive.exe
$UserFolders = Get-WmiObject -Class Win32_UserProfile -Filter "special=false AND loaded=false" | select -ExpandProperty LocalPath

# Begin removal process
$Count = 0
Foreach($Folder in $UserFolders){
    $Count += 1
    &cmd.exe /c rd /s /q $Folder
    Write-Progress -Activity "Removing user folders..." -Status "$Folder" -PercentComplete ($Count/$UserFolders.Count*100)
}
Get-WmiObject -Class Win32_UserProfile -Filter "special=false AND loaded=false" | Remove-WmiObject

