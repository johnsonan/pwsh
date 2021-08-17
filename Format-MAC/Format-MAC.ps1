Function Format-MacAddress {

    Param ( $MacAddress )

    $MacAddress -replace '..(?!$)', '$&:'

}