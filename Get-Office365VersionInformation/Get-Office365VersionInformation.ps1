Function Get-Office365VersionInformation {

    Param(
        
        [CmdletBinding()]

        [Parameter(Mandatory=$True)]
        $ComputerName
        
    )

    $VersionObj = ForEach ($Computer in $ComputerName) {

        $PropertyObj = Invoke-Command -ComputerName $Computer -ScriptBlock { 
            
            Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | ? DisplayName -match "Microsoft Office 365 ProPlus"

        }

        $Version = $PropertyObj.DisplayVersion

        [pscustomobject]@{"ComputerName"=$Computer; "Version"=$Version}

    }

    $VersionObj

}