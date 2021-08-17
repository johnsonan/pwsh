$Members = Get-LocalGroupMember -Group Administrators
If ($Members.Name -Contains "DOMAIN\Domain Users"){
    
    $false

}else{
    
    $true

}