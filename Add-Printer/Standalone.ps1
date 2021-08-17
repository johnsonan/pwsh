Param(

    [Parameter(
        Mandatory=$true
    )]
    [ValidateSet("\\print1", "\\print2", "\\print3")]
    [String]
    $PrintServer,
    
    [Parameter(
        Mandatory=$true
    )]
    [ValidateNotNullOrEmpty()]
    [String]
    $PrinterName,

    [Parameter(
        Mandatory = $false
    )]
    [switch]
    $Force,

    $Verbose = $true
    
)

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

# Initialize remote print queue details
try {

    $RemotePrinter = Get-Printer -ComputerName $PrintServer -Name $PrinterName -ErrorAction Stop
    Write-Verbose "Getting printer info from $PrintServer\$PrinterName"

} catch {

    throw "Unable to find network printer at: $PrintServer\$PrinterName"

}

$RemoteDriver  = Get-PrinterDriver -ComputerName $PrintServer -Name $RemotePrinter.DriverName | Select-Object -First 1
$RemoteInfPath = $RemoteDriver.InfPath | Select-Object -First 1
$DriverFolder  = $RemoteInfPath.Split("\")[-2]

# Test driver for existing installation
$LocalDriver = Get-LocalDriver -FolderName $DriverFolder -RemoteDriverName $RemoteDriver.Name

if ($LocalDriver -and !$Force) {

    # Use existing inf file
    $LocalInf = $LocalDriver.InfPath

} else {

    # Proceed with installation
    $Environment   = ("W32X86", "x64")[$RemoteInfPath -match "amd64"]
    $RemoteCab     = "$PrintServer\print$\$Environment\PCC\$DriverFolder.cab"

    # Stage temp directory for driver files
    $NewGuid = "{$((New-Guid).Guid.ToUpper())}"
    $TempDir =  New-Item "C:\Windows\Temp\$NewGuid" -ItemType Directory

    # Expand Cab file
    $ExpandOutput = &expand.exe "$RemoteCab" "$TempDir" -F:*

    if ($ExpandOutput[-2] -notmatch "Complete") {

        throw "Error expanding $RemoteCab to $TempDir."

    } else {

        Write-Verbose "Successfully expanded $($ExpandOutput[-1].Split(" ")[0]) files from $RemoteCab to $TempDir."

    }

    # Get local Inf path and install it
    $CabInfPath = (Get-ChildItem -Path $TempDir -Filter "*.inf").FullName

    # PnPUtil to stage remote print driver
    $RawOutput = pnputil -a "$CabInfPath" #| Select-String "Published name"

    if ($RawOutput[-2][-1] -eq 0) {

        # If successful, the index referenced above will equal 1
        throw "Processing pnputil on inf failed at $CabInfPath."

    } else {

        # Pull out published inf name and grab its path
        try {

            $PublishedName = $RawOutput.Where({ $_ -match "inf" })[-1].Split(" ")[-1]
            $LocalInf = (Get-ChildItem -Path "C:\Windows\INF\$PublishedName" -ea Stop).FullName

        } catch {

            throw "Unable to find $PublishedName at C:\Windows\INF."

        }
        
    }

}

# Check for existing printer structures
$PrinterDriver = Get-PrinterDriver -Name $RemoteDriver.Name -ea SilentlyContinue
$PrinterPort   = Get-PrinterPort -Name $RemotePrinter.PortName -ea SilentlyContinue
$Printer       = Get-Printer -Name $RemotePrinter.Name -ea SilentlyContinue

# Add printer structures if necessary
if (!$Force) {

    if (!$PrinterDriver) {

        Add-PrinterDriver -Name $RemotePrinter.DriverName -InfPath $LocalInf

    } else {

        Write-Verbose "Using existing printer driver."

    }

    if (!$PrinterPort) {

        Add-PrinterPort -Name $RemotePrinter.PortName -PrinterHostAddress $RemotePrinter.PortName

    } else {

        Write-Verbose "Using existing printer port."

    }

    if (!$Printer) {

        Add-Printer -Name $RemotePrinter.Name -PortName $RemotePrinter.PortName -DriverName $RemotePrinter.DriverName

    } else {

        throw "Printer with the name $($RemotePrinter.Name) already exists. Exiting."

    }

} else {

    try {

        Remove-Printer -Name $RemotePrinter.Name -ea SilentlyContinue
        Remove-PrinterPort -Name $RemotePrinter.PortName -ea SilentlyContinue
        Remove-PrinterDriver -Name $RemotePrinter.DriverName -ea SilentlyContinue

    } catch {

        Write-Verbose "$PSItem"

    } finally {

        Add-PrinterDriver -Name $RemoteDriver.Name -InfPath $LocalInf
        Add-PrinterPort -Name $RemotePrinter.PortName -PrinterHostAddress $RemotePrinter.PortName
        Add-Printer -Name $RemotePrinter.Name -PortName $RemotePrinter.PortName -DriverName $RemotePrinter.DriverName

    }

}