Function Test-PathTimeout ($Path, $Milliseconds) {
    $PsCmd = [PowerShell]::Create().AddScript("Test-Path $Path")

    $Handle = $PsCmd.BeginInvoke()

    if (-not $Handle.AsyncWaitHandle.WaitOne($Milliseconds)) {
        $Result = $false
    } else {
        $Result = $PsCmd.EndInvoke($Handle)
    }

    [PSCustomObject]@{
        "Path" = $Path
        "Result" = $Result
    }
}