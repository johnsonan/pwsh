Function Get-ShareSize ([string]$Path) {
    if (Test-Path $Path) {
        $Size = (Get-ChildItem $Path -File -Recurse | Measure-Object -Sum Length | Select -expand Sum) / 1MB

        return [PSCustomObject]@{
            Path = $Path
            Size = $Size
        }
    } else {
        Write-Warning "Path does not exist at: $Path"
    }
}