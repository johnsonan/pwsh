Function Get-CMApplicationContentLocation {

    [CmdletBinding()]
    param (
    
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $CMApplication
    
    )
    
    Begin {
    
        # Import ApplicationManagement assemblies from AdminConsole path
        Set-Location -Path "C:\"
        [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
        [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
    
    }
    
    Process {
    
        $AppManagement = ([xml]$CMApplication.SDMPackageXML).AppMgmtDigest
        $AppName = $AppManagement.Application.DisplayInfo.FirstChild.Title
    
        ForEach ($DeploymentType in $AppManagement.DeploymentType) {
    
            # Fill properties
            $AppData = [PSCustomObject]@{            
                AppName  = $AppName
                Location = $DeploymentType.Installer.Contents.Content.Location
		Files    = $DeploymentType.Installer.Contents.Content.File.Name -join ", "
                Size = (($DeploymentType.Installer.Contents.Content.File.Size | Measure-Object -Sum).Sum)/1MB
                DeploymentTypeXml = $DeploymentType
            }                           
        
            # Return it
            $AppData
    
        }
    
    }
    
    End { 
    
        Set-Location YOURSITECODE:
    
    }

}

Function New-CMRequiredApplicationDeployment {

    Param(
        [Parameter(Mandatory = $True)]
        [string[]]$CollectionNames,
        [string[]]$ApplicationNames,

        [Parameter(Mandatory = $False)]
        [System.Boolean]$DistributeContent = $False,
        [System.Boolean]$UpdateSupersedence = $False
    )

    try {

        $Module = "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
        $SiteCode = "YOURSITECODE:"
    
        Import-Module $Module -ErrorAction Stop
        Set-Location $SiteCode -ErrorAction Stop
    
    }
    catch {

        throw $($Error)[0]

    }

    ForEach ($App in $ApplicationNames) {

        ForEach ($Coll in $CollectionNames) {

            if ($DistributeContent -eq $True) {

                $ParamSplat = @{
                    Name                  = $App
                    CollectionName        = $Coll
                    DeployPurpose         = "Required"
                    UserNotification      = "DisplaySoftwareCenterOnly"
                    SendWakeupPacket      = $True
                    DistributionPointName = "YOUR.DIST.POINT"
                    DistributeContent     = [System.Boolean]$True
                    UpdateSupersedence    = [System.Boolean]$UpdateSupersedence
                }

            }
            else {

                $ParamSplat = @{

                    Name               = $App
                    CollectionName     = $Coll
                    DeployPurpose      = "Required"
                    UserNotification   = "DisplaySoftwareCenterOnly"
                    SendWakeupPacket   = $True
                    UpdateSupersedence = [System.Boolean]$UpdateSupersedence

                }
            }


            try {

                New-CMApplicationDeployment @ParamSplat -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
                [PSCustomObject]@{Application = "$App"; Collection = "$Coll"; Status = "Success"}

            } catch {

                [PSCustomObject]@{Application = "$App"; Collection = "$Coll"; Status = $PSItem}

            }

        }

    }

}

Function Get-CMDetectionMethod {

    Param(
        [Parameter(Mandatory=$True)]
        [string]$SearchString
    )

    $DirLocations = @(
        "C:\Program Files",
        "C:\Program Files (x86)"
    )

    $RegLocations = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $Directories = ForEach ($Dir in $DirLocations) {

        Get-ChildItem $Dir | ? Name -match $SearchString | Select -ExpandProperty FullName

    }

    $RegEntries = ForEach ($Reg in $RegLocations) {

        Get-ItemProperty $Reg | ? DisplayName -match $SearchString 

    }

    if ($Directories) {

        Write-Host "`nDirectories matching search term [$SearchString] found: "
        $Directories

    }
    if ($RegEntries) {

        Write-Host "`nRegistry entries matching search term [$SearchString] found: "
        $RegEntries

    }
    else {

        Write-Host "`nNo directories or registry entries identified for search term [$SearchString]."

    }


}