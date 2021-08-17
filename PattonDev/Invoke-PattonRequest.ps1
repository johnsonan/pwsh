Function Invoke-PattonRequest {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory = $true )]
        [string]
        $Uri,

        [Parameter( Mandatory = $false )]
        [ValidateSet(
            "Get",
            "Post"
        )]
        [string]
        $Method,

        [hashtable]
        $Headers,

        [hashtable]
        $Form
    )

    begin {}

    process {

        # Cred key for Basic auth
        $Key = "###"

        # Headers hashtable
        $Headers = @{

            "Authorization"             = "Basic $Key"
            "Upgrade-Insecure-Requests" = "1"
            "User-Agent"                = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.85 Safari/537.36 Edg/90.0.818.49"
            "Accept"                    = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
            "Accept-Encoding"           = "gzip, deflate"
            "Accept-Language"           = "en-US,en;q=0.9"

        }

        # Upload cfg
        if ($Form) {

            Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers -Form $Form

        } else {

            Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Headers

        }

    }

    end {}
}