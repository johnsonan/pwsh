Function Get-PSStartupItem {

    [CmdletBinding(DefaultParameterSetName = "Scope")]

    Param (

        [Parameter(
            Mandatory = $false
        )]
        [string]
        $Name,
        
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $User,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = "Scope"
        )]
        [ValidateSet("AllUsers", "CurrentUser")]
        [string]
        $Scope = "AllUsers"

    )

    Begin {

        if ($Scope -eq "AllUsers") {

            # Location hashtable
            # Contains paths to common startup locations for all users
            $UserLocations = @{

                "File" = @(
                    ":UserPath\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
                )

                "Registry" = @(
                    "Registry::HKEY_USERS\:UserSID\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
                )

            }

            $SystemLocations = @{

                "File" = @(
                    "C:\ProgramData\Start Menu\Programs\StartUp"
                )

                "Registry" = @(
                    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
                    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
                    "HKLM:\DefaultUser\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
                )

            }

        } else {
            
            # Location hashtable
            # Contains paths to common startup locations for current user
            $Locations = @{

                "File" = @(
                    "$Env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
                )

                "Registry" = @(
                    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
                )

            }

        }

    }

    Process {

        if ($Scope -eq "AllUsers") {

            # Get all user profiles
            $Users = Get-WmiObject -Class Win32_UserProfile -Namespace root/cimv2 -Filter "Special = False"

            # Load default user hive
            

            &REG LOAD "HKLM\DefaultUser" "C:\Users\Default\NTUSER.DAT" | Out-Null

            if (!(Test-Path "HKLM:\DefaultUser")) {

                throw "Unable to load default user registry hive from C:\Users\Default\NTUSER.DAT into HKLM\DefaultUser."

            } else {

                Write-Verbose "Default user registry hive loaded into HKLM\DefaultUser from C:\Users\Default\NTUSER.DAT"

            }

            # Get system location items
            $SystemItems = ForEach ($Type in $SystemLocations.Keys) {

                # Iterate over lookup table keys and list values
                # Check each path for items and return object if found
                ForEach ($Path in $SystemLocations[$Type]) {


                    if (!(Test-Path $Path)) {

                        Write-Verbose "Unable to locate path, skipping.`n$Path`n"
                        continue

                    }

                    if ($Type -eq "File") {

                        $StartupItem = Get-ChildItem -Path $Path -Recurse

                        if ($StartupItem) {

                            ForEach ($Item in $StartupItem) {

                                [PSCustomObject]@{
        
                                    User = "System"
                                    Name = $Item.Name
                                    Type = "File"
                                    Path = $Item.FullName
            
                                }

                            }
        
                        } else {
        
                            Write-Verbose "No startup files found at path:`n$Path`n"
        
                        }

                    } else {

                        $Properties = $(Get-Item -Path "$Path").Property

                        if ($Properties) {

                            ForEach ($Property in $Properties) {

                                [PSCustomObject]@{
        
                                    User = "System"
                                    Name = $Property
                                    Type = "Registry"
                                    Path = $Path
            
                                }

                            }

                        } else {

                            Write-Verbose "No startup properties located at path:`n$Path`n"

                        }

                    }

                }

            }


            # Get startup items for all users
            $UserItems = ForEach ($UserProfile in $Users) {

                # Iterate over lookup table keys and list values
                # Check each path for items and return object if found
                ForEach ($Type in $UserLocations.Keys) {

                    ForEach ($Path in $UserLocations[$Type]) {

                        # Format user details
                        $Username = $($UserProfile.LocalPath.Split("\"))[-1]
                        $UserPath = $UserProfile.LocalPath
                        $Sid = $UserProfile.SID

                        # Format path with user details
                        $Path = $Path.Replace(":UserSID", $Sid)
                        $Path = $Path.Replace(":UserPath", $UserPath)

                        if (!(Test-Path $Path)) {

                            Write-Verbose "Unable to locate path, skipping.`n$Path`n"
                            continue

                        }

                        if ($Type -eq "File") {

                            $StartupItem = Get-ChildItem -Path $Path -Recurse

                            if ($StartupItem) {

                                ForEach ($Item in $StartupItem) {

                                    [PSCustomObject]@{
            
                                        User = $Username
                                        Name = $Item.Name
                                        Type = "File"
                                        Path = $Item.FullName
                
                                    }
    
                                }
            
                            } else {
            
                                Write-Verbose "No startup files found at path:`n$Path`n"
            
                            }

                        } else {

                            $Properties = $(Get-Item -Path "$Path").Property

                            if ($Properties) {

                                ForEach ($Property in $Properties) {

                                    [PSCustomObject]@{
            
                                        User = "$Username"
                                        Name = $Property
                                        Type = "Registry"
                                        Path = $Path
                
                                    }
    
                                }

                            } else {

                                Write-Verbose "No startup properties located at path:`n$Path`n"

                            }
     
                        }
    
                    }

                }

            }
            
            # Return startup items by Name, Username
            # default Username and Name value = ".*"
            $StartupItems = $SystemItems + $UserItems
            $StartupItems | Where-Object {$_.Name -match $Name -and $_.User -match $User}

        } else {

            # Current user logic
            $StartupItems = ForEach ($Type in $Locations.Keys) {

                ForEach ($Path in $Locations[$Type]) {

                    if (!(Test-Path $Path)) {

                        Write-Verbose "Unable to locate path, skipping.`n$Path`n"
                        continue

                    }

                    if ($Type -eq "File") {

                        $StartupItem = Get-ChildItem -Path $Path -Recurse

                        if ($StartupItem) {

                            ForEach ($Item in $StartupItem) {

                                [PSCustomObject]@{
        
                                    User = $env:USERNAME
                                    Name = $Item.Name
                                    Type = "File"
                                    Path = $Item.FullName
            
                                }

                            }

                        } else {

                            Write-Verbose "No startup files found at path:`n$Path`n"

                        }

                    } else {

                        $Properties = $(Get-Item -Path $Path).Property

                        if ($Properties) {

                            ForEach ($Property in $Properties) {

                                [PSCustomObject]@{
                                    Username = $env:USERNAME
                                    Name = $Property
                                    Type = "Registry"
                                    Path = $Path
                                }

                            }

                        } else {

                            Write-Verbose "No startup properties found at path:`n$Path`n"

                        }

                    }

                }

            }

            # Return startup items matching $Name
            # default $Name = ".*"
            $StartupItems | Where-Object Name -match "$Name"

        }

    }

    End {

        # Unload default user hive
        if (Test-Path "HKLM:\DefaultUser") {

            # Invoke garbage collector, otherwise unload fails due to lock
            [GC]::Collect()
            [GC]::WaitForPendingFinalizers()

            &REG UNLOAD "HKLM\DefaultUser" > null 2>&1

            if (Test-Path "HKLM:\DefaultUser") {

                throw "Unable to unload default user registry hive from HKLM\DefaultUser."

            } else {

                Write-Verbose "Successfully unloaded default user registry hive from HKLM\DefaultUser."

            }

        }

     }

}