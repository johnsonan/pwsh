Function Remove-PSStartupItem {

    [CmdletBinding(DefaultParameterSetName = "File")]

    Param (

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Name,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateSet("File", "Registry")]
        [string]
        $Type,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Path,

        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $Force

    )

    Begin { }

    Process {

        # Handle case where Registry path is passed but not $Name
        if ($Type -eq "Registry" -and !$Name) {

            throw "Startup items of type 'Registry' require a Name value."

        }

        # Load default registry hive if necessary
        if ($Path -match "DefaultUser") {

            &REG LOAD "HKLM\DefaultUser" "C:\Users\Default\NTUSER.DAT" | Out-Null

            if (!(Test-Path "HKLM:\DefaultUser")) {

                throw "Unable to load default user registry hive from C:\Users\Default\NTUSER.DAT into HKLM\DefaultUser."

            } else {

                Write-Verbose "Default user registry hive loaded into HKLM\DefaultUser from C:\Users\Default\NTUSER.DAT"

            }

        }

        # Initialize status flag
        $Status = ""

        # Remove items
        $Removed = switch ($Type) {

            "Registry" {

                try {

                    if ($Force) {

                        Remove-ItemProperty -Path $Path -Name $Name -Force
                    
                    } else {
    
                        Remove-ItemProperty -Path $Path -Name $Name
                    
                    }

                    $Status = "Removed"

                } catch {

                    $Status = "Failed"

                } finally {

                    [PSCustomObject]@{

                        Name   = $Name
                        Type   = $Type
                        Path   = $Path
                        Status = $Status

                    }

                }

            }

            "File" {

                try {

                    if ($Force) {

                        Remove-Item -Path $Path -Force
    
                    } else {
    
                        Remove-Item -Path $Path
    
                    }

                    $Status = "Removed"

                } catch {

                    $Status = "Failed"

                } finally {

                    [PSCustomObject]@{

                        Name   = $Name
                        Type   = $Type
                        Path   = $Path
                        Status = $Status

                    }

                }

            }

        }

        # Return removed items
        $Removed

    }

    End {

        # Unload default user hive
        if (Test-Path "HKLM:\DefaultUser") {

            # Invoke garbage collector, otherwise unload fails due to lock
            [GC]::Collect()
            [GC]::WaitForPendingFinalizers()

            &REG UNLOAD "HKLM\DefaultUser" > null 2>&1

            if (Test-Path "HKLM:\DefaultUser") {

                throw "Unable to unload default user registry hive from HKLM\DefaultUser."

            } else {

                Write-Verbose "Successfully unloaded default user registry hive from HKLM\DefaultUser."

            }

        }

     }

}