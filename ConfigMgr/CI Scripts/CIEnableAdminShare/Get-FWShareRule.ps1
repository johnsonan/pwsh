$Rules = Get-NetFirewallRule -DisplayGroup "File and Printer Sharing"

switch ($Rules){

    {$_.Action -contains "Block"}
    {
        $Result = $False
    }

    {$_.Enabled -contains "False"}
    {
        $Result = $False
    }

    default
    {
        $Result = $True
    }
}

$Result