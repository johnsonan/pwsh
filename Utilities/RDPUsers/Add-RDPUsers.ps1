Function Add-RDPUsers {

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string[]]
        $ComputerName,

        [string[]]
        $User
    )

    Begin { }

    Process {

        $Jobs = Invoke-Command -ComputerName $ComputerName -AsJob -ScriptBlock {

            Add-LocalGroupMember -Group "Remote Desktop Users" -Member $using:User

            $LocalUsers = Get-LocalGroupMember -Group "Remote Desktop Users" | Select -ExpandProperty Name

            [PSCustomObject]@{

                Members = $LocalUsers

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