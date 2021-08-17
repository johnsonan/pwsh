Function Expand-CABFile {

    [CmdletBinding()]
    param (

        [Parameter(
            Mandatory = $true
        )]
        [string]
        $Path,

        [Parameter(
            Mandatory = $true
        )]
        [string]
        $Destination

    )

    Begin { }

    Process {

        # Expand Cab file
        $ExpandOutput = &expand.exe "$Path" "$Destination" -F:*

        if ($ExpandOutput[-2] -notmatch "Complete") {

            throw "Error expanding $Path to $Destination.`n$PSItem`n"

        } else {

            Write-Verbose "Successfully expanded $($ExpandOutput[-1].Split(" ")[0]) files from $RemoteCab to $TempDir."

            # Return expanded directory
            Get-Item -Path $Destination

        }

    }

    End { }

}