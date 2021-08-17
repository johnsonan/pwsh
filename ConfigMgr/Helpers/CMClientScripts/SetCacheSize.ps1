[CmdletBinding()]
param (
    [Parameter(
        Mandatory = $true
    )]
    [ValidateNotNullOrEmpty()]
    [int]
    $CacheSize
)

$UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
$Cache = $UIResourceMgr.GetCacheInfo()
$Cache.TotalSize = $CacheSize
Restart-Service -Name CcmExec