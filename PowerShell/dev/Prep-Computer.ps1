function Prep-Computer {

    #$Creds = Get-Credential

    $Profiles = Get-CimInstance -ClassName Win32_UserProfile #| Where {(!$_.Special)}

    foreach ($i in $Profiles) {

        echo $i
        echo "-----------------------------------------------------------"

    }
    
    #Remove-Computer -UnjoinDomainCredential $Creds -WorkgroupName Temp

    #Start-Sleep -Seconds 5

    #Add-Computer -Credential $Creds -DomainName firstlightpower.com

}