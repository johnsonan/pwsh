<#    
.SYNOPSIS    
  Invoke installation of available software updates on remote computers using Run Script CM console feature
     
.DESCRIPTION    
 Script that will Invoke installation of available software updates on remote computers in Software Center that's available for the remote computer.     
     
.NOTES    
    FileName:    Trigger-CMSoftwareUpdates.ps1    
    Author:      Andrew Johnson      
    Created:     01-13-2020
      
#>

$ApplicationClass = [WmiClass]"root\ccm\clientSDK:CCM_SoftwareUpdatesManager" 

$Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate | Where-Object { $_.EvaluationState -like "*0*" -or $_.EvaluationState -like "*1*" })
Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Application) -Namespace root\ccm\clientsdk
