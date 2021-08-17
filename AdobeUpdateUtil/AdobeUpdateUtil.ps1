Function Get-AdobeVersion {

    $RegPath32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    $RegPath64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

    $UninstallKeys = $(Get-ItemProperty $RegPath32\*) + $(Get-ItemProperty $RegPath64\*) | %{$_.PSPath.Split("\")[-1]}

    $ProductIDs = @{
        "{A0BB5DD8-8867-46C3-A44A-BF54E68145F2}" = "Adobe CC 2017 Core Apps"
        "{1084B627-49AA-4653-B4E6-F075666A4337}" = "Adobe CC 2017 Full Suite" 
        "{6157AD40-828D-4570-AF52-BEA56B2220DA}" = "Adobe CC 2017 Full Suite v2"
        "{58708D0A-9851-4022-8DE4-294FBEAE5759}" = "Adobe CC 2018 CC App"
        "{AC09123E-8096-4495-8A5D-97064B7A7F25}" = "Adobe CC 2018 CC App v2"
        "{35ACD1A6-B972-4EB7-8583-9A02C3E9E6BA}" = "Adobe CC 2018 Full Suite"
        "{F132AF7F-7BCA-4EDE-8A7C-958108FE7DBC}" = "Dev Test"
    }

    $DetectedVersions = $ProductIDs.Values | %{

        if($UninstallKeys -contains $_){
            return $ProductIDs[$_]
            Write-Host "test"
        }

    }

}