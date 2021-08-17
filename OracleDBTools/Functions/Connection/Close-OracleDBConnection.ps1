Function Close-OracleDBConnection {

    <#
    .SYNOPSIS
        Disposes of the active $Script:Connection variable.

    .DESCRIPTION
        This function closes and disposes of an existing $Connection variable within
        the script scope.

    .INPUTS
        This function takes no input from the pipeline.

    .OUTPUTS
        This function returns no output - it instead calls the Close() and Dispose()
        methods on the script-scope $Connection object, then clears its value.

    .EXAMPLE
        # Create Oracle DB connection object
        New-OracleDBConnection -BaseUri "baseuri.contoso.com" -Port 8003 -DataSource "Test" -Credential (Get-Credential)

        # ...
        # Do something
        # ...

        # Close Oracle DB connection object
        Close-OracleDBConnection
    #>

    [CmdletBinding()]
    Param ()

    Begin { }

    Process {

        try{

            if ($Script:Connection.Status -eq "Open") {

                $Script:Connection.Close()                
                Write-Verbose "Connection closed successfully."
            
            }
            
            $Script:Connection.Dispose()

        } catch {

            throw $PSItem

        } finally {

            Clear-Variable -Name Connection -Scope Script -ErrorAction SilentlyContinue

        }

    }

    End { }

}