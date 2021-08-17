# This script will take the printer name as a parameter and intall it for all users.
Param(
  [Parameter(Mandatory=$True)]
    [String]
    $printServer,

 [Parameter(Mandatory=$True)]
    [String]
    $printerName
)


#The printer name will be passed in as a value...
#$printServer = "\\org-others"

write-host "Your selected printer is $printerName"
$pathToSMB = "\\some\folder\PrinterDrivers\"


#Create Lists for Printers...
#$printServers = @("\\org-canon", "\\org-others", "\\org-hp")


#pipe each printer server to the foreach loop 
#$allPrinters = $printServers | %{ Get-Printer -ComputerName $_ }
$allPrinters = Get-Printer -ComputerName $printServer

#Get the printers IP, Driver, Print Server
foreach($name in $allPrinters){ 
if($printerName -Match $name.'Name'){
$server = "\\"+$name.'ComputerName'
$ip=$name.'PortName'
$printerDriverName = $name.'DriverName'
write-host "The IP for"$printerName" is "$ip
write-host "The Driver for "$printerName" is "$printerDriverName
write-host "Print Server: "$server
    }
}

#Get Printers INF
$infPath = Get-PrinterDriver -ComputerName $server -Name $printerDriverName | Select 'InfPath' 
$infPath = $infPath.'InfPath'

#If INF path returns an array get the first item... Hopefully the amd64 driver
if($infPath.Count -gt 1){
$infPath = $($infPath[0]).ToString()
Write-Host $infPath}


#Copy the driver to C:\Windows\System32\DriverStore\FileRepository\  -Doesn't work
#So i'm going to copy the driver to C:\Temp\<Driver Folder>
#If driver install from the print server fails, the script will copy the drivers to a temp folder for install

$folderName = $infPath -replace ".*FileRepository\\" -replace "\\.*"
$smbPathToDriver = $pathToSMB+$folderName
#$Target = "C:\temp\"+$folderName
#$Target = "C:\Windows\System32\DriverStore\FileRepository\"+$folderName
copy-item -path $smbPathToDriver $Target -recurse -Force
write-host "Driver Location is $infPath"
$inf = $infPath -replace '.*\\'
$tempInfPath = $Target+"\"+$inf

#SMB INF Path:  Use this first. If the driver install fails use copy drivers from org-image
$smbInfPath = Get-ChildItem -Path $smbPathToDriver -Filter "*.inf" | Select -ExpandProperty FullName

if($smbInfPath -gt 1) {

    $smbInfPath = $smbInfPath[0]

}

$Source = $smbPathToDriver  
#(Get-Acl $Source).Access #Verify $Source Access
#(Get-Acl $Target).Access #Verify $Target Access


#Add the driver...
#pnputil.exe -a "$infPath"
#pnputil.exe -a "$smbInfPath"


$pnpOutput = pnputil -a "$smbInfPath" | Select-String "Published name" 
$null = $pnpOutput -match "Published name :\s*(?<name>.*\.inf)"
$driverINF = Get-ChildItem -Path C:\Windows\INF\$($matches.Name)
Add-PrinterDriver -Name $PrinterDriverName -InfPath $driverINF.FullName


#Add-PrinterDriver; portName and ip are the same. I just kept different names for syntax clarity..
$portName = $ip
$portExists = Get-Printerport -Name $portname -ErrorAction SilentlyContinue

#If port doesn't exist, add port...
if (-not $portExists) {
  Add-PrinterPort -name $portName -PrinterHostAddress $ip
  write-host "Added Printer Port $portName"
}


$printDriverExists = Get-PrinterDriver -name $printerDriverName -ErrorAction SilentlyContinue
write-host $printerDriverExists

    #If driver exists ADD PRINTER!
    if ($printDriverExists) {
        Add-Printer -Name $printerName -PortName $portName -DriverName $printerDriverName
    }else{
        Write-Warning "Printer Driver not installed"
    }


   
