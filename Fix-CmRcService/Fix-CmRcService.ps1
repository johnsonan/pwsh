$cim = Get-Ciminstance  -Namespace 'ROOT\ccm\Policy\Machine\ActualConfig' -Class CCM_RemoteTools_Policy
$cim.AudibleSignal = 0
Set-CimInstance -InputObject $cim

Set-Service -Name CmRcService -StartupType Automatic
Start-Service -Name CmRcService 