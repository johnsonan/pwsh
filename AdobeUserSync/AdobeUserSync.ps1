<#

Author: Andrew Johnson
Date:   12/13/2019

Requirements:

    1) 3.6.2 >= Python <= 3.6.8
        One of the following:
        * Enable long filepath support
        * Add short (C:\pex) PEX_ROOT env variable

        Python must be installed as administrator in all-users mode.

    2) The following files must be configured in the parent folder of $UserSyncFile
        - connector-csv.yml     [Default configuration]
        - user-sync-config.yml  [Modified to support CSV]


Description:

    This script iterates over a list of OUs defined in $SearchBases and gets AD users
    listed therein. AD user objects are then casted to the defined AdobeUser class and
    sorted by Faculty, Staff, Student Worker, and Student by its constructor depending
    on the ADUser object's identifying properties - see below:

        extensionAttribute14 -eq "StudentWorker"    :   Student Worker
        extensionAttribute15 -eq "FacultyStaff"     :   Faculty or Staff
        extensionAttribute10 -eq "org.edu"          :   Student

    The order in which the above properties are evaluated is important. See the class
    constructor for more info in the comments.

    After casting all relevant ADUsers to AdobeUser objects, the objects are piped out
    to a CSV file. This CSV file is then synced with the Adobe adminconsole directory.
    This is a push sync for performance and API rate limit reasons - the Adobe directory
    is not checked for group membership, simply overwritten on each sync.

#>

# Path to Adobe user sync pex file
$UserSyncFile = "C:\User_Sync\user-sync.pex"

# Import AD module for initial lookups
Import-Module -Name ActiveDirectory

#region Class definitions
# Initialize Adobe user class
Class AdobeUser {

    [string] $firstname
    [string] $lastname
    [string] $email
    [string] $country
    [string] $groups
    [string] $domain
    [string] $type

    AdobeUser($ADUser) {

        # Set initial values
        $this.firstname = $ADUser.GivenName
        $this.lastname  = $ADUser.Surname
        $this.email     = $ADUser.Mail
        $this.country   = "US"
        $this.type      = "FederatedId"

        # ! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !
        # ! The order of conditionals below is important !
        # ! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !
        # Student Workers should eval first - some also have FacultyStaff for ext15
        # Faculty/Staff should eval before Students - some are also Students
        
        # Student worker case
        if ($ADUser.extensionAttribute14 -eq "StudentWorker") {

            $this.groups = "Student Workers"
            $this.domain = "org.com"

        }
        # Faculty/Staff case
        elseif ($ADUser.extensionAttribute15 -eq "FacultyStaff") {

            $this.groups = "Faculty/Staff"
            $this.domain = "org.com"

        }
        # Student case
        elseif ($ADUser.extensionAttribute10 -eq "my.org.com") {

            $this.groups = "Students"
            $this.domain = "my.org.com"

        }

    }

}
#endregion

#region Variable declarations
# Initialize list of OUs for SearchBase
$SearchBases = @(

    "OU=SomeOU,DC=SomeOrg",
    "OU=SomeOU,DC=SomeOrg",
    "OU=SomeOU,DC=SomeOrg",
    "OU=SomeOU,DC=SomeOrg",

)

# Initialize splat parameters
$SearchParam = @{

    SearchScope = "Subtree"
    SearchBase  = ""
    Filter      = { Enabled -eq $true }
    Properties  = @(

        "mail",
        "extensionAttribute10",
        "extensionAttribute14",
        "extensionAttribute15"

    )

}
#endregion

#region Processing
# Populate list of AdobeUser objects
$AdobeUsers = ForEach ($SearchBase in $SearchBases) {

    # Only check child user objects for Students and ITS OU
    switch -Wildcard ($SearchBase) {

        "OU=Students*" { $SearchParam.SearchScope = "OneLevel" }
        "OU=ITS*"      { $SearchParam.SearchScope = "OneLevel" }

    }

    # Get ADUsers from searchbase
    $SearchParam.SearchBase = $SearchBase
    $ADUsers = Get-ADUser @SearchParam

    # Convert to AdobeUser objects
    ForEach ($ADUser in $ADUsers) {

        $UserFlag = $ADUser.extensionAttribute10 -or `
                    $ADUser.extensionAttribute14 -or `
                    $ADUser.extensionAttribute15

        if ($UserFlag) {

            [AdobeUser]::New($ADUser)

        }

    }

}

#region Output
# Get user sync directory
$UserSyncFolder = (Get-Item -Path $UserSyncFile).Directory.FullName

# Export CSV to sync directory
$AdobeUsers | Export-Csv -Path "$UserSyncFolder\AdobeUsers.csv" -NoTypeInformation -Encoding ASCII -Force

# Start push to Adobe directory
Set-Location -Path $UserSyncFolder
& python `"$UserSyncFile`" --process-groups