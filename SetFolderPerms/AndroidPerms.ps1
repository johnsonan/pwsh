$Devs = Get-Content C:\Users\johnsonan\Desktop\devs.txt
Foreach($Dev in $Devs){
    Invoke-Command -AsJob -ComputerName $Dev -ScriptBlock {
        $ACL = Get-Acl C:\android
        $ACLObj = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit, ObjectInherit", "InheritOnly", "Allow")
        $ACL.AddAccessRule($ACLObj)

        Set-Acl -Path C:\Users\Default\.AndroidStudio3.1 $ACL
        Set-Acl -Path C:\Users\Default\.android $ACL
        Set-Acl -Path C:\Users\Default\.gradle $ACL

        Start-Process cmd.exe -ArgumentList "/c", "icacls 'C:\Users\Default\.AndroidStudio3.1\*' /q /c /t /reset"
        Start-Process cmd.exe -ArgumentList "/c", "icacls 'C:\Users\Default\.android\*' /q /c /t /reset"
        Start-Process cmd.exe -ArgumentList "/c", "icacls 'C:\Users\Default\.gradle\*' /q /c /t /reset"
    }
}