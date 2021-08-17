$Item = Get-Item "C:\Windows\System32\atig6pxx.dll" -ea SilentlyContinue

if ($Item) {

    $true

} else {

    $false

}