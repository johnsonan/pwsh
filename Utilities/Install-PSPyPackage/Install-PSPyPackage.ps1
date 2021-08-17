# Initialize script path
$AnacondaPath = "C:\ProgramData\Anaconda3\"
$PythonPath = "C:"


#This accounts for different versions of Python so the right folder is selected
#doesnt fully work because all computers have a C drive so the test-path will always be true
if(Test-Path $PythonPath){
    $Version = (Get-ChildItem $PythonPath | Select-String -Pattern 'Python')
    $PythonPath = "$PythonPath\$Version\Scripts"
} else {
    throw "Python is not installed. Exiting."
    exit 1
}




Function Test-PSPyPackage {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$PackageName

    )
    #$Result = &$PythonPath show $PackageName
    $Result = Start-Process -FilePath "$PythonPath\pip.exe" -ArgumentList "show $PackageName" -PassThru -Wait -WindowStyle Hidden
    if($Result.ExitCode -eq 0){
        return $True
    } else {
        return $False
    }
}


# Install Py Packages 

Function Install-PSPyPackage {

    Param(

        [Parameter(Mandatory=$True)]
        [string]$PackageName
    )
    
    # Install package using PyScript
    Start-Process -FilePath "$PythonPath\pip.exe" -ArgumentList "install $PackageName","-q" -Wait
    }

# Remove Py Packages 
Function Remove-PSPyPackage {

    Param(

        [Parameter(Mandatory=$True)]
        [string]$PackageName

    )
    
    # Install package using PyScript
    Start-Process -FilePath "$PythonPath\pip.exe" -ArgumentList "uninstall $PackageName","-q","-y" -Wait

}