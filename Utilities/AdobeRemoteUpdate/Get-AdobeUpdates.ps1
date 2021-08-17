Function Get-AdobeUpdates {

    [CmdletBinding()]
    param (

        [Parameter(
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $RUMPath,

        [Parameter(
            Mandatory = $false
        )]
        [ValidateSet(
            "After Effects",
            "Animate and Mobile Device Packaging",
            "Audition",
            "Bridge",
            "Character Animator",
            "Dimension",
            "Dreamweaver",
            "Illustrator",
            "InCopy",
            "InDesign",
            "Lightroom",
            "Lightroom Classic",
            "Media Encoder",
            "Photoshop",
            "Prelude",
            "Premiere Pro",
            "Premiere Rush",
            "XD"
        )]
        [string[]]
        $Product
        
    )

    if ($Product) {

        # If product is specified, initialize code map
        $ProductMap = @{

            "After Effects"                       = "AEFT"
            "Animate and Mobile Device Packaging" = "FLPR"
            "Audition"                            = "AUDT"
            "Bridge"                              = "KBRG"
            "Character Animator"                  = "CHAR"
            "Dimension"                           = "ESHR"
            "Dreamweaver"                         = "DRWV"
            "Illustrator"                         = "ILST"
            "InCopy"                              = "AICY"
            "InDesign"                            = "IDSN"
            "Lightroom"                           = "LRCC"
            "Lightroom Classic"                   = "LTRM"
            "Media Encoder"                       = "AME"
            "Photoshop"                           = "PHSP"
            "Prelude"                             = "PRLD"
            "Premiere Pro"                        = "PPRO"
            "Premiere Rush"                       = "RUSH"
            "XD"                                  = "SPRK"

        }

        # Pull out code from map using product name
        $ProductCodes = $Product.ForEach({$ProductMap[$PSItem]})

        # Build productVersion string from list of codes
        $ProductString = "--productVersion=$($ProductCodes -join ", ")"

        # Append string to full LookupString
        $LookupString = "$RUMPath --action=list $ProductString"

    } else {

        # If product isn't specified, pull all updates
        $LookupString = "$RUMPath --action=list"

    }

    # Call full LookupString commandline
    $Output = &cmd /c $LookupString

    # Pull out updates
    $Updates = $Output.Where({ $_ -match "\([A-Za-z].*\)" }).Trim()

    # Return sanitized update names
    if ($Updates) {

        $Updates -replace "[()]"

    } else {

        if ($Product) {

            "No updates available for specified prducts:`n$Product"

        } else {

            "No updates available."

        }

    }

}