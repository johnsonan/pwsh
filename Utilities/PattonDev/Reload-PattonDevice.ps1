Function Reload-PattonDevice {

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $IPAddress
    )

    begin { }

    process {

        # Build full reload Uri
        $ReloadUri = "http://$IPAddress/reboot-prog.html"

        # Reload
        try {

            $Result = Invoke-PattonRequest -Uri $ReloadUri

            if ($Result -match "The system is going down") {

                "$($IPAddress): Success"

            } else {

                throw "Malformed response"

            }

        } catch {

            $Error[0]

        }
        

    }

    end { }
    
}