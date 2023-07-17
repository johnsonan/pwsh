Function Get-FastADLookup ([string[]]$EmployeeIds) {
    
    # Get all domain controllers
    $DCs = Get-ADDomainController -Filter * | Where-Object {$_.Hostname -notmatch "ECSUAZ"} | Select-Object -ExpandProperty Hostname

    # Split employeeId list into chunks based on number of DCs
    $Counter = [PSCustomObject] @{ Value = 0 }
    $ChunkSize = [math]::Ceiling($EmployeeIds.Count / $DCs.Count)
    $Chunks    = $EmployeeIds | Group-Object -Property { [math]::Floor($Counter.Value++ / $ChunkSize) }

    # Distribute chunks among DCs as jobs
    $Jobs = ForEach ($Chunk in $Chunks) {
        Start-Job -ScriptBlock {
            param ($Chunk, $DCs)
            ForEach ($Id in $Chunk.Group) {
                Get-ADUser -Filter {employeeId -eq $Id} -Server $DCs[$Chunk.Name]
            } 
        } -ArgumentList $Chunk, @($DCs)
    }

    # Return job results once complete
    $Jobs | Wait-Job | Receive-Job

}