Function Invoke-OracleDBQuery {

    <#
    .SYNOPSIS
        Executes a SELECT statement against the Oracle $Connection object.

    .DESCRIPTION
        This function accepts a SQL query string and runs it against the existing
        script-wide $Connection object. It returns an object of type [System.Data.DataTable]
        containing the rows and columns returned by the query in tabular format, as well as the
        Oracle DataAdapter object embedded in $DataTable.ExtendedProperties.DataAdapter for dynamic
        UPDATEs.

    .INPUTS
        This function takes no input from the pipeline.

    .OUTPUTS
        This function returns an object of type [System.Data.DataTable] containing the rows 
        and columns returned by the query in tabular format, as well as the Oracle DataAdapter 
        object embedded in $DataTable.ExtendedProperties.DataAdapter for dynamic UPDATEs. This allows
        the use of $DataTable.ExtendedProperties.DataAdapter.Update($DataTable) to return updated rows
        to the $Connection object automatically.

    .EXAMPLE
        # Get datatable containing results
        $Results = Invoke-OracleDBQuery -QueryString "SELECT * FROM table1 WHERE column1 = 'demo'"

        # Select row from table
        $RowOfInterest = $Results.Where({ $_.column2 -eq "Demo" })

        # Modify value
        $RowOfInterest.column2 = "Testing"

        # Push updates back to DB
        $Results.ExtendedProperties.DataAdapter.Update($Results)

    #>

    [CmdletBinding()]

    param (

        # The $QueryString parameter accepts a string
        # representing the SQL query string passed to the
        # $Connection object. Semi-colons will be removed.
        [Parameter(
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $QueryString,

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
        $Command.CommandText = $QueryString.Replace(";","")

        # Get Oracle data adapter
        $DataAdapter  = New-Object -TypeName Oracle.ManagedDataAccess.Client.OracleDataAdapter($Command)

        # Fill data table with results from adapter
        $ResultsTable = New-Object -TypeName System.Data.DataTable
        [void]$DataAdapter.Fill($ResultsTable)
        
        if ($null -ne $ResultsTable) {

            # Save DataAdapter in extended properties
            # This allows us to create a CommandBuilder in the calling function
            # Enables dynamic update functionality in Set-GOREMALRecord
            $ResultsTable.ExtendedProperties.DataAdapter = $DataAdapter

            # Return results, must use "@(,...)" since DataTable isn't an IEnumerable type
            # "," forces powershell to receive it as an array of a single value
            # which won't try to unroll the table...
            @(,$ResultsTable)

        } else {

            Write-Warning "No results found for query string:`n$QueryString`n"

        }

    }

    End { }

}