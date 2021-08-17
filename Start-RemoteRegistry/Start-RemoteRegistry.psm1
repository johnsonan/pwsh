Function Start-RemoteRegistry{
    
    Param(

        [Parameter(Mandatory=$True)]
        [string[]]$ComputerName
    
    )

    ForEach($Name in $ComputerName){

        Set-Service -ComputerName $Name -Name RemoteRegistry -StartupType Automatic

    }

}