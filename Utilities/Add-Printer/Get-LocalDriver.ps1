Function Get-LocalDriver {

    Param(

        [Parameter(
            Mandatory = $true
        )]
        [string]
        $FolderName,

        [Parameter(
            Mandatory = $true
        )]
        [string]
        $RemoteDriverName

    )

    # Initialize driver store and INF path
    $DriverStore = "C:\Windows\System32\DriverStore\FileRepository"
    $InfFolder   = "C:\Windows\INF"

    # Check for existing driver path locally
    $LocalDriver = Get-Item "$DriverStore\$FolderName" -ea SilentlyContinue

    # Check for local inf
    $InstalledInf = &pnputil.exe -e
    $InfNames = $InstalledInf.Where({ $_ -match "Published name" }).ForEach({ $_.Split(" ")[-1] })

    # Loop through inf names and check their content for matching driver name
    $LocalInf = ForEach ($Inf in $InfNames) {

        $InfContent = Get-Content "$InfFolder\$Inf" -ea SilentlyContinue

        if ($InfContent -match "$($RemoteDriverName)") {

            # Return inf file matching remote driver
            $Inf

        }

    }

    if (($LocalDriver -and $LocalInf)) {

        [PSCustomObject]@{

            DriverPath = "$DriverStore\$LocalDriver"
            InfPath    = "$InfFolder\$LocalInf"

        }

    } else {

        Write-Verbose "No inf or driver located."

    }

}