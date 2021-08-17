
 
[CmdletBinding()] 
param 
( 
         
    [Parameter(Mandatory = $true)] 
    [ValidateSet(
        'MachinePolicy', 
        'DiscoveryData', 
        'ComplianceEvaluation', 
        'AppDeployment',  
        'HardwareInventory', 
        'UpdateDeployment', 
        'UpdateScan', 
        'SoftwareInventory'
    )] 
    [string]$ClientAction
         
) 


# Build hashtable for mapping param to value
$ScheduleIDMappings = @{
         
    'MachinePolicy'        = '{00000000-0000-0000-0000-000000000021}'
    'DiscoveryData'        = '{00000000-0000-0000-0000-000000000003}'
    'ComplianceEvaluation' = '{00000000-0000-0000-0000-000000000071}'
    'AppDeployment'        = '{00000000-0000-0000-0000-000000000121}'
    'HardwareInventory'    = '{00000000-0000-0000-0000-000000000001}' 
    'UpdateDeployment'     = '{00000000-0000-0000-0000-000000000108}' 
    'UpdateScan'           = '{00000000-0000-0000-0000-000000000113}'
    'SoftwareInventory'    = '{00000000-0000-0000-0000-000000000002}'

}

# Map parameter string to WMI value         
$ScheduleID = $ScheduleIDMappings[$ClientAction]
         
# Execute policy WMI method
[void] ([wmiclass] "\\$($args[0])\root\ccm:SMS_Client").TriggerSchedule($args[1])

