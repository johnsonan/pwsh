# Initialize Rscript path
$RPath   = "C:\Program Files\R"

if(Test-Path $RPath){
    $Version = (Get-ChildItem $RPath | Sort -Property Name -Descending)[0] | Select -ExpandProperty Name 
    $BinPath = "$RPath\$Version\bin"
} else {
    throw "R not installed. Exiting."
    exit 1
}

# Set library ACL - BUILTIN\Users FullControl
Function Set-PSRLibraryAcl {

    Param (
        [Parameter(Mandatory=$False)]
        [string]$LibraryPath = "$RPath\$Version\library"
    )

    if (!(Test-Path $LibraryPath)) {

        throw "R library directory not found, exiting."
        exit

    } else {

        $ACL      = Get-ACL -Path $LibraryPath
        $RuleArgs = @("BUILTIN\Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $Rule     = New-Object System.Security.AccessControl.FileSystemAccessRule($RuleArgs)
        $ACL.AddAccessRule($Rule)
        $ACL | Set-ACL $LibraryPath

    }

}

Function Get-PSRLibraryAcl {

    Param (
        [Parameter(Mandatory=$False)]
        [string]$LibraryPath = "$RPath\$Version\library"
    )
    if (!(Test-Path $LibraryPath)) {

        throw "R library directory not found, exiting."
        exit

    } else {

        $ACL = Get-ACL -Path $LibraryPath
        $Result = $ACL.Access | ? { $_.IdentityReference -match "BUILTIN\\Users" -and $_.FileSystemRights -eq "FullControl" }

        # If $Result not empty or null
        if ($null -ne $Result) {

            return $Result

        }
    }
}

# Install traditional R Packages 
Function Install-PSRPackage {

    Param(

        [Parameter(Mandatory=$True)]
        [string]$PackageName,
        [string]$RepositoryURI

    )
    
    # Install package using RScript
    Start-Process -FilePath "$BinPath\Rscript.exe" -ArgumentList "-e", "`"install.packages('$PackageName', repos='$RepositoryURI')`"" -Wait

}

# Install BioConductor R packages
Function Install-PSBiocPackage {
    Param(

        [Parameter(Mandatory=$True)]
        [string]$PackageName

    )

    if(Test-PSRPackage -PackageName "BiocManager"){

        # Install package using RScript
        Start-Process -FilePath "$BinPath\Rscript.exe" -ArgumentList "-e", "`"BiocManager::install('$PackageName')`"" -Wait

    } else {
        throw "BiocManager not installed. Exiting."
        exit 0
    }
}

# Test traditional and BioC packages
Function Test-PSRPackage {

    Param(

        [Parameter(Mandatory=$True)]
        [string]$PackageName

    )

    $Result = Start-Process -FilePath "$BinPath\Rscript.exe" -ArgumentList "-e", "`"find.package('$PackageName')`"" -PassThru -Wait -WindowStyle Hidden

    if($Result.ExitCode -eq 0){
        return $True
    } else {
        return $False
    }

}

# Remove traditional R Packages 
Function Remove-PSRPackage {

    Param(

        [Parameter(Mandatory=$True)]
        [string]$PackageName

    )
    
    # Install package using RScript
    Start-Process -FilePath "$BinPath\Rscript.exe" -ArgumentList "-e", "`"remove.packages('$PackageName')`"" -Wait

}

# Execute arbitrary R script using Rscript.exe
Function Execute-PSRScript {

    Param(

        [Parameter(Mandatory=$True)]
        [string]$ScriptPath

    )
    
    &"$BinPath\Rscript.exe" "$ScriptPath"

}