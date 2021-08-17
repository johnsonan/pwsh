Function Set-FolderACL {

    [CmdletBinding()]

    Param(

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("FullName", "LocalPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserPrincipal,

        [Parameter(
            Mandatory = $true
        )]
        [ValidateSet("FullControl", "Modify", "Read", "Write", "ReadAndExecute")]
        [string[]]
        $Rights,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet("Allow", "Deny")]
        [string]
        $AccessType = "Allow"

    )

    Begin { }

    Process {

        $ACL      = Get-ACL -Path $Path
        $RuleArgs = @("$UserPrincipal", "$Rights", "ContainerInherit,ObjectInherit", "None", "$AccessType")
        $Rule     = New-Object System.Security.AccessControl.FileSystemAccessRule($RuleArgs)

        $ACL.AddAccessRule($Rule)
        $ACL | Set-ACL $Path

    }

    End { }

}