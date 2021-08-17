#Set permissions for unity licensing...

$acl = Get-Acl C:\ProgramData\Unity\Unity_lic.ulf
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users","FullControl","Allow")
$acl.SetAccessRule($AccessRule)
$acl | Set-Acl C:\ProgramData\Unity\Unity_lic.ulf