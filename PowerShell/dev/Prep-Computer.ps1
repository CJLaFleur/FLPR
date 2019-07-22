function Prep-Computer {

    # MAKE SURE TO FORMAT YOUR CREDENTIALS AS FOLLOWS: "firstlightpower.com\cjlafleur"

    $Creds = Get-Credential
    
    $Domain = "FIRSTLIGHTPOWER.COM"

    Get-CimInstance -ClassName Win32_UserProfile | Where {($_.LocalPath -NE "C:\Users\ITD" -AND !$_.Special -AND $_.Loaded -EQ $FALSE)} | Remove-CimInstance
    
    Remove-Computer -Credential $Creds -Force

    Add-Computer -Credential $Creds -DomainName $Domain
    
    Restart-Computer

}