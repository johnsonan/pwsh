Param(
[Parameter(Mandatory=$True)]
[String]$PackageID
)

$UI = New-Object -ComObject "UIResource.UIResourceMgr"
$UI.ExecuteProgram("*",$PackageID,$True)