function Prep-Win7 {

    # This script is written for PS V 2.0

    # MAKE SURE TO FORMAT YOUR CREDENTIALS AS FOLLOWS: "firstlightpower.com\cjlafleur"

    $Creds = Get-Credential
    
    $Domain = "FIRSTLIGHTPOWER.COM"

    Get-WmiObject Win32_UserProfile | Where {($_.LocalPath -NE "C:\Users\ITD" -AND !$_.Special -AND $_.Loaded -EQ $FALSE)} | Remove-WmiObject
    
    Remove-Computer -Credential $Creds -Force

    Add-Computer -Credential $Creds -DomainName $Domain
    
    Restart-Computer

}