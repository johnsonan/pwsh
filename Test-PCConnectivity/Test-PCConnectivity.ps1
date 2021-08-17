Function Test-PCConnectivity {

    Param(

        [Parameter(
            Mandatory = $true
        )]
        [string[]]
        $ComputerName

    )

    Begin { }

    Process {

        $TestPath = Test-Path "\\$ComputerName\C$"

        if ($TestPath) {

            [PSCustomObject]@{
                "ComputerName" = $ComputerName
                "Online"       = $true
            }

        } else {

            [PSCustomObject]@{
                "ComputerName" = $ComputerName
                "Online"       = $false
            }

        }

    }

    End { }

}