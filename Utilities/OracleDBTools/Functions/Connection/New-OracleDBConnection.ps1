Function New-OracleDBConnection {

    <#
    .SYNOPSIS
        Brokers a connection to an Oracle database using DB credentials.

    .DESCRIPTION
        This function takes a base uri, data source, port, and db local credentials and then
        creates a connection to the given databse. The connection is created in the "Script" scope
        which allows other functions within this module to leverage the existing connection without
        the need to pass a connection variable.

    .INPUTS
        This function takes no input from the pipeline.

    .OUTPUTS
        This function returns no output - it instead creates a $Connection variable in the script scope
        which is referenced in subsequent functions as $Script:Connection.

    .EXAMPLE
        New-OracleDBConnection -BaseUri "baseuri.contoso.com" -Port 8003 -DataSource "Test" -Credential (Get-Credential)
    #>

    [CmdletBinding()]

    Param (

        # The $BaseUri parameter accepts a string
        # representing the URI at which the datasource
        # is hosted.
        [parameter(
			Mandatory = $true
		)]
        [ValidateNotNullOrEmpty()]
        [string]$BaseUri,

        # The $Port parameter accepts a string
        # representing the port at which the baseuri and
        # datasource expose the database.
        [parameter(
			Mandatory = $true
		)]
        [string]$Port,

        # The $DataSource parameter accepts a string
        # representing the location at which the database
        # resides.
        # Example:
        #   https://testdb.contoso.com/<$DataSource>:<$Port>
        [parameter(
			Mandatory = $true
		)]
        [string]$DataSource,

        # The $Credential parameter accepts a PSCredential
        # object representing the username and password of
        # a local database credential pair.
        [parameter(
			Mandatory = $true
		)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential

    )

    Begin {

        try {

            # Locate Oracle assembly
            $NugetPackage = (Get-Package Oracle.ManagedDataAccess -ea Stop).Source
    
        } catch [System.Exception] {
    
            # Install it if it isn't found
            if ($PSItem.CategoryInfo.Category -eq "ObjectNotFound") {
    
                $Package = (Install-Package Oracle.ManagedDataAccess -ProviderName NuGet -Scope AllUsers -Force).Payload.Directories[0]
                $NugetPackage = Join-Path -Path $Package.Location -ChildPath $Package.Name
                Remove-Variable -Name "Package"
    
            }
            else {
    
                throw $PSItem
    
            }
    
        }

        #Load Oracle assembly into session
        Add-Type -Path (Get-ChildItem (Split-Path ($NugetPackage) -Parent) -Filter "Oracle.ManagedDataAccess.dll" -Recurse -File)[0].FullName

    }

    Process {

        # Pull credential details from PSCredential
        $Username = $($Credential.UserName)
        $Password = $($Credential.GetNetworkCredential().Password)

        # Build connection string
        $ConnectionString = "Data Source=$BaseUri`:$Port/$DataSource;User Id=$Username;Password=$Password"

        try {

            # Create and open connection object
            $Conn = New-Object -TypeName Oracle.ManagedDataAccess.Client.OracleConnection($ConnectionString)
            $Conn.Open()

        } catch {

            throw $PSItem

        } finally {

            if ($Conn.State -eq "Open") {

                $Script:Connection = $Conn
    
            } else {

                throw "Unable to open connection for`nData Source = $BaseUri`:$Port/$DataSource`nUser = $Username"

            }

        }

    }

    End { }

}