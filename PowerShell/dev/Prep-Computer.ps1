function Prep-Computer {

    # MAKE SURE TO FORMAT YOUR CREDENTIALS AS FOLLOWS: "firstlightpower.com\clafleur"

    [cmdletbinding()]
    Param(

        [Parameter(Mandatory = $False,
        Position = 0,
        HelpMessage ="Enter the primary user on this device")]
        [String] $User

        )

    $Creds = Get-Credential
    
    $Domain = "FIRSTLIGHTPOWER.COM"

    Get-CimInstance -ClassName Win32_UserProfile | Where {($_.LocalPath -NE "C:\Users\$User" -AND !$_.Special -AND $_.Loaded -EQ $False)} | Remove-CimInstance
    
    Remove-Computer -Credential $Creds -Force

    .\scanstate.exe d:\chopp /i:miguser.xml /i:migapp.xml /o /c

    Add-Computer -Credential $Creds -DomainName $Domain

    $OU = Get-ADOrganizationalUnit -LDAPFilter "(name=Computers)"

    Get-ADComputer -LDAPFilter "(name=$($env:COMPUTERNAME))" | Move-ADObject -TargetPath $OU.DistinguishedName
    
    Restart-Computer

}