[CmdletBinding()]
param (
    [Parameter(
        Mandatory = $true
    )]
    [string]
    $FilePath
)

Test-Path -Path $FilePath