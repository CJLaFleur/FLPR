function Prep-Computer {

    # MAKE SURE TO FORMAT YOUR CREDENTIALS AS FOLLOWS: "firstlightpower.com\clafleur"

    [cmdletbinding()]
    Param(

        [Parameter(Mandatory = $True,
        HelpMessage ="Enter the primary user on this device")]
        [String] $User,

        [Parameter(Mandatory = $True,
        HelpMessage ="Enter the name of the computer to be copied from")]
        [String] $OldComputer,

        [Parameter(Mandatory = $True,
        HelpMessage ="Enter the name of the computer to be copied to")]
        [String] $NewComputer

        )

    BEGIN {

    $Creds = Get-Credential
    
    $Domain = "FIRSTLIGHTPOWER.COM"

    }

    PROCESS {

    Get-WmiObject -ComputerName $OldComputer -ClassName Win32_UserProfile | Where {($_.LocalPath -NE "C:\Users\$User" -AND !$_.Special -AND $_.Loaded -EQ $False)} | Remove-WmiObject

    Invoke-Command -ComputerName $OldComputer -Credential $Creds -ScriptBlock { \\burapp017\scanstate.exe \\datastore\$OldComputer /i:miguser.xml /i:migapp.xml /o /c }
    
    Remove-Computer -Credential $Creds -Force

    Restart-Computer -Force

    Add-Computer -ComputerName $NewComputer -Credential $Creds -DomainName $Domain

    \\burapp017\loadstate.exe /i:migapp.xml /i:miguser.xml \\datastore\$OldComputer /all /progress:progress.log /l:load.log /c /lac

    $OU = Get-ADOrganizationalUnit -LDAPFilter "(name=Computers)"

    Get-ADComputer -LDAPFilter "(name=$($NewComputer))" | Move-ADObject -TargetPath $OU.DistinguishedName
    
    Restart-Computer

    }

}