Function Push-PattonConfig {

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $FilePath,

        [string]
        $IPAddress
    )

    begin { }

    process {

        # Build full upload Uri
        $UploadUri = "http://$IPAddress/imp-cfg-prog.html"

        # Build form input file
        $Form = @{

            "INPUT_FILE:/flash/nvram/startup-config" = Get-Item $FilePath
        
        }

        # Upload cfg
        Invoke-PattonRequest -Uri $UploadUri -Method Post -Headers $AuthHeaders -Form $Form

    }

    end { }
    
}