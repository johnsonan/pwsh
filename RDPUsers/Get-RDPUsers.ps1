Function Get-RDPUsers {

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string[]]
        $ComputerName
    )

    Begin { }

    Process {

        $Jobs = Invoke-Command -ComputerName $ComputerName -AsJob -ScriptBlock {

            $Users = Get-LocalGroupMember -Group "Remote Desktop Users" | Select -ExpandProperty Name

            [PSCustomObject]@{

                Members = $Users

            }

        }

    }

    End {

        $Membership = $Jobs | Wait-Job | Receive-Job

        ForEach ($Member in $Membership) {

            [PSCustomObject]@{

                ComputerName = $Member.PSComputerName
                Members      = $Member.Members -join ", "

            }

        }

    }

}