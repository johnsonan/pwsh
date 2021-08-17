Function Import-ScheduledTask {

    param(

        [ValidateScript({
            if(-Not ($_ | Test-Path)){
                throw "File or folder does not exist."
            }
            if(-Not ($_ | Test-Path -PathType Leaf)){
                throw "The path argument must reference a file, not a directory."
            }
            if($_ -notmatch "\.xml"){
                throw "The path argument must reference an xml file."
            }
            return $true
        })]

        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$Path,

        [string]$ComputerName = "localhost"

    )
    
    $TaskName    = (Get-Item -Path $Path | Select-Object -ExpandProperty Name).Split('.')[0]
    $TaskContent = Get-Content -Path $Path | Out-String

    Invoke-Command -ComputerName $ComputerName -ArgumentList $TaskName, $TaskContent -ScriptBlock {

        Register-ScheduledTask -TaskName $args[0] -Xml $args[1] -Force

    }

}