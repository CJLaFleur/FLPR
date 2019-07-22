function Prep-Win7 {

    # MAKE SURE TO FORMAT YOUR CREDENTIALS AS FOLLOWS: "firstlightpower.com\cjlafleur"

    $Creds = Get-Credential
    
    $Domain = "FIRSTLIGHTPOWER.COM"

    Get-WmiObject Win32_UserProfile | Where {($_.LocalPath -NE "C:\Users\ITD" -AND !$_.Special -AND $_.Loaded -EQ $FALSE)} | Remove-WmiObject
    
    Remove-Computer -Credential $Creds -Force

    Add-Computer -Credential $Creds -DomainName $Domain
    
    Restart-Computer

}