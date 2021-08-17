Param(

    [Parameter(Mandatory=$True)]
    [ValidateSet("Reboot Thawed", "Reboot Frozen", "End Maintenance", "Unlock", "Lock")]
    [String[]]
    $Action,

    [Parameter(Mandatory=$True)]
    [String]
    $Password

)

Filter DFStateFilter {

    if($_ -match "Frozen") {

        if($CurrentState) {

            "Computer already frozen."
            exit 0

        }
        else {

            "/BOOTFROZEN"

        }

    }

    if($_ -match "Thawed") {

        if($CurrentState) {
            
            "/BOOTTHAWED"

        }
        else {

            "Computer already thawed."
            exit 0

        }
    }

    if($_ -match "Maintenance") {

        "/ENDTASK"
    
    }

    if($_ -match "Unlock") {

	"/UNLOCK"

    }

    if($_ -eq "Lock") {
    
        "/LOCK"

    }
}

$DFCPath = "C:\Windows\SysWOW64\DFC.exe"
try {

    $CurrentState = $(Start-Process -FilePath $DFCPath -ArgumentList "get", "/ISFROZEN" -PassThru -Wait -ea Stop).ExitCode
    "Frozen: $CurrentState"
    $CLIAction = $Action | DFStateFilter

} catch {

    "Failed to retrieve or analyze DF state, exiting. : $($Error[0])"
    exit 1

}

if($null -ne $CLIAction) {

    try {

        "Running Action: $($CLIAction.Replace('/', ''))"
        Start-Process -FilePath $DFCPath -ArgumentList $Password, $CLIAction -ea Stop
        "Action $($CLIAction.Replace('/', '')) completed successfully."

    } catch { 
        
        "Failed to launch DFC process, exiting. : $($Error[0])"

    }
    finally {

        

    }

}
else {

    "CLIAction cannot be null."

}