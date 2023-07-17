Function ConvertFrom-ExcelClip {
    Param(
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $ClipText
    )

    if ([string]::IsNullOrEmpty($ClipText)) {
        $ClipText = [System.Windows.Forms.Clipboard]::GetText()
    }

    # Pull out headers and rows, assuming first row are headers
    $Formatted = $ClipText.Trim().Split("`n")
    $Headers = ($Formatted[0] -split "\s{2,}").Trim()
    $Rows = @($Formatted[1..($Formatted.Count-1)]).Trim()

    # Convert to PSObject and return
    $Objs = ForEach ($Row in $Rows) {

        $Columns = ($Row -split "\s{2,}").Trim()
        $Obj = [PSCustomObject]@{}

        for ($i = 0; $i -lt $Headers.Count; $i++) {
            $Obj | Add-Member -MemberType NoteProperty -Name $Headers[$i] -Value $Columns[$i]
        }

        $Obj
    }

    return $Objs

}