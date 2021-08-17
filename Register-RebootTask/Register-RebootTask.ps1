Function Register-RebootTask {

    Param(
    
        [Parameter(
            Mandatory = $true
        )]
        [scriptblock]
        $ScriptBlock


    )

    Begin {

        # Create temp staging directory
        $Dir = New-Item "C:\Windows\Temp\$(New-GUID)" -ItemType Directory | Select -ExpandProperty FullName
    
        # Create temporary PS script
        $GUID = New-Guid
        $ScriptFile = New-Item "$Dir\$GUID.ps1" | Select -ExpandProperty FullName

        # Create temporary cmd script wrapper
        $CmdWrapper = New-Item "$Dir\$GUID.cmd"
        "powershell.exe -ExecutionPolicy Bypass -File $ScriptFile" | Add-Content -Path $CmdWrapper -Encoding Ascii

    }

    Process {

        # Append each scriptblock line to the ps1 file
        $ScriptBlock | Out-String | Out-File $ScriptFile -Append

    }

    End {

        # Generate GUID for task name
        $TaskName = New-Guid

        # Append task removal to end of PS script
        "Unregister-ScheduledTask -TaskName $TaskName -Confirm:`$false" | Add-Content -Path $ScriptFile -Encoding Ascii

        # Generate scheduled task
        $Action = New-ScheduledTaskAction -Execute $($CmdWrapper.FullName)
        $Schedule = New-ScheduledTaskTrigger -AtStartup
        $Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        $Settings = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -WakeToRun -DontStopIfGoingOnBatteries -Hidden -AllowStartIfOnBatteries
        $Task = New-ScheduledTask -Action $Action -Trigger $Schedule -Principal $Principal -Settings $Settings
        Register-ScheduledTask $TaskName -InputObject $Task

    }

}