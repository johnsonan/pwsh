$Users = Get-LocalGroupMember -Group "Administrators" | Select -ExpandProperty Name

if ($Users -contains "DOMAIN\Domain Users") {

    $true

} else {

    $false

}