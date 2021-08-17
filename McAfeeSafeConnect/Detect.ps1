$RegPath = "HKLM:\SOFTWARE\McAfee Safe Connect"
if(Test-Path $RegPath){
    $True
}else{
    $False
}