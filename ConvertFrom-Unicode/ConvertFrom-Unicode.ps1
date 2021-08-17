Function ConvertFrom-Unicode {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $UnicodeString
    )

    $UnicodeString = $UnicodeString -replace "U\+| |U\\", ""

    $UnicodeArray = @()
    
    ForEach ($Char in $UnicodeString) {

        $IntValue = [System.Convert]::ToInt32($Char, 16)
        [System.Char]::ConvertFromUtf32($IntValue)
        $UnicodeArray += [System.Char]::ConvertFromUtf32($IntValue)

    }

    $UnicodeArray -join [String]::Empty

}