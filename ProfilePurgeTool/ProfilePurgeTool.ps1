$Date = Get-Date -Format "ddMMyyyyHHmm"
Start-Transcript -Path "C:\UDLogs\$Date.log" -Verbose

Write-Host "Getting User profiles..."
$Users = Get-ChildItem "C:\Users" | ? Name -notmatch "Public|Default|lifad"
Write-Host $Users

####################################################
# Analysis Routine:                                #
#     1. For each user, collect list of subfolders #
#     2. Pass each subfolder through switch filter #
#     3. If not OD or AppData, add to pending del. #
####################################################
Write-Host "Starting analysis routine..."
$DelFolders = ForEach($User in $Users) {
    
    Write-Host "Getting $($User.Name) subfolders..."
    $FullPath   = $User.FullName
    $SubFolders = Get-ChildItem $FullPath
    Write-Host $SubFolders
    
    Write-Host "Passing subfolders through item-level filter..."
    switch -Wildcard ($SubFolders) {

        ({$PSItem.Name -match "OneDrive*"})
            { Write-Host "OneDrive detected - skipping." }

        ({$PSItem.Name -match "AppData*" }) 
            { Write-Host "AppData detected - skipping." }

        ({$PSItem.Name -match "Favorites*" }) 
            { Write-Host "Favorites detected - skipping." }

        default      
            { $PSItem.FullName }

    }
}

####################################################
# Deletion Routine:                                #
#     1. For each folder to delete, try deleting.  #
#     2. If successful, add to final report.       #
#     3. If not successful, log it and move on.    #
####################################################
$DelReport = ForEach($Folder in $DelFolders) {

    try { 
        
        Write-Host "[$(Get-Date -Format "HH:mm")] - Deleting $Folder contents..."
        Remove-Item -Path "$Folder\*" -Recurse -Exclude "*desktop.ini*" -ErrorAction Stop
        "$Folder"

    } 
    catch {
        
        Write-Host "[$(Get-Date -Format "HH:mm")] - Failed to delete $Folder contents..."
        Write-Error $Error[0]

    }

}

# End summary stats.
$DelCount = $DelReport.Count
$TotalCount = $DelFolders.Count

Write-Host "[$(Get-Date -Format "HH:mm")] - Process complete - $DelCount/$TotalCount folders purged."

Stop-Transcript