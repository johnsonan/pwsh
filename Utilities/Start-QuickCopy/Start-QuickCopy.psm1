Function Start-QuickCopy {

    Param(
        [ValidateScript({
            if ($PSItem -match "(?<!\\)$") { 
                $True
            } else {
                throw "Source path cannot contain trailing backslash."
            }
        })]
        [string]$Source,
        [string]$Destination
    )

    # Get bottom-level directory name from source
    $SourceFolder = $Source.Split("\")[-1]

    # Logic to ensure that destination contains matching directory name for robocopy
    # e.g. source = C:\Test, destination must be C:\some\path\Test
    if ($Destination.Split("\")[-1] -ne $SourceFolder) {

        if ($Destination[-1] -eq "\") {
        
            $Destination = "$Destination$SourceFolder"
        
        }
        else {

            $Destination = "$Destination\$SourceFolder"

        }
    }

    # Start robocopy with args
    $RoboOpts = @("/S", "/MT:25", "/NP", "/NFL", "/NDL", "/E")
    $RoboArgs = @("$Source", "$Destination", $RoboOpts) 

    robocopy @RoboArgs
}