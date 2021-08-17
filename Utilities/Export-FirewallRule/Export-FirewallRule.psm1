function Export-FirewallRule{

    Param(

        [Parameter(
            Mandatory = $True
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $SearchString,

        [Parameter(
            Mandatory = $True
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Destination

    )

    $RegHeader = "Windows Registry Editor Version 5.00"
    $RegPath = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules"
    $Output = $RegHeader + "`r`n`r`n" + "[$RegPath]"

    &cmd.exe /c reg export $RegPath $Destination
    
    $FWRules = Get-Content $Destination

    ForEach($Line in $FWRules){
    
        if($Line -match $SearchString){
            $Output += "`r`n$Line"
        }

    }

    $Output | Out-File $Destination
    
}
