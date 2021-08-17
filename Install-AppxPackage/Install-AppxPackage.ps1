Param(

	[Parameter(Mandatory=$true)]
	[string]
	$PackagePath

)

Add-AppxProvisionedPackage -PackagePath $PackagePath -SkipLicense -Online