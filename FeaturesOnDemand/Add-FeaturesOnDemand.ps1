Function Add-FeaturesOnDemand {

    Param (

        [Parameter(

            Mandatory = $true

        )]
        [string]
        $FeatureName

    )

    Begin {

        $CurrentWU = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | select -ExpandProperty UseWUServer
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
        Restart-Service wuauserv

    }

    Process {

        Add-WindowsCapability -Online -Name $FeatureName

    }

    End {

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $currentWU
        Restart-Service wuauserv

    }

}