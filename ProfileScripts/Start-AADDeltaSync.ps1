Function Start-AADDeltaSync ([string]$AADSyncHost) {
    $Session = New-PSSession $AADSyncHost
    Invoke-Command -Session $Session -ScriptBlock {Import-Module -Name 'ADSync'}
    Invoke-Command -Session $Session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
    Remove-PSSession $Session
}