Function Invoke-OracleDBNonQuery {
    <#
    .SYNOPSIS
        Executes an UPDATE, DELETE, or other non-query string against the DB connection.

    .DESCRIPTION
        This function accepts a non-query SQL string and runs it against the existing
        script-wide $Connection object. If the -PassThru parameter is specified, the affected rows
        are returned.

    .INPUTS
        This function takes no input from the pipeline.

    .OUTPUTS
        This function returns affected rows if the -PassThru parameter is supplied.

    .EXAMPLE
        $AffectedRows = Invoke-DBNonQuery -NonQueryString "UPDATE customers SET first_name = 'Judy' WHERE customer_id = 8000" -PassThru
    #>
    
    [CmdletBinding()]

    param (

        # The $NonQueryString parameter accepts a string
        # representing the SQL NonQuery string being passed
        # to the $Connection object. Semi-colons will be removed.
        [Parameter(
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $NonQueryString,

        # The $PassThru parameter is a switch allowing
        # the function to return the number of rows affected
        # by the NonQuery.
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $PassThru,
        
        # The $Connection parameter accepts a value
        # representing the current database connection.
        # The default value is the script-wide $Connection
        # returned by New-OracleDBConnection, but can be
        # overridden.
        [Parameter(
            Mandatory = $false
        )]
        $Connection = $Script:Connection

    )

    Begin {

        # Check that $Script:Connection exists and is open
        if ($null -eq $Script:Connection) {

            throw "Connection is null. Run New-OracleDBConnection to begin."

        }
        elseif ($Script:Connection.State -eq "Closed") {

            throw "Connection is closed. Run New-OracleDBConnection to begin."

        }

     }

    Process {

        # Build command object with query string
        $Command = $Connection.CreateCommand()
        $Command.CommandText = $NonQueryString.Replace(";","")

        # Initialize AffectedRows to 0
        $AffectedRows = 0

        # Execute non-query
        try {

            $AffectedRows = $Command.ExecuteNonQuery()

            Write-Verbose "$AffectedRows rows were affected by the non-query:`n$NonQueryString`n"

            if ($PassThru) {

                # Return number of rows affected
                $AffectedRows
    
            }

        } catch [System.InvalidOperationException] {

            # Catch closed object invalid op, means connection is not open
            if ($PSItem.Exception.Message -match "closed object") {

                throw "Oracle connection is closed. Run New-OracleDBConnection and try again."

            } else {

                throw "Error executing non-query:`n$NonQueryString`n$PSItem"

            }

        } catch {

            throw "Error executing non-query:`n$NonQueryString`n$PSItem"

        }

    }

    End { }

}