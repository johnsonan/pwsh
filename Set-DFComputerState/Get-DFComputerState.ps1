$DFCPath = "C:\Windows\SysWOW64\DFC.exe"
try{
    $CurrentState = $(Start-Process -FilePath $DFCPath -ArgumentList "get", "/ISFROZEN" -PassThru -Wait -ea Stop).ExitCode
    "Frozen: $CurrentState"
} catch {
    "Error, idk"
}
