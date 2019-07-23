function Test-Network {

[cmdletbinding()]
    Param(

        [Parameter(Mandatory = $True,
        Position = 0,
        HelpMessage ="Specify the subnets you wish to scan.")]
        [Alias('Multiple')]
        [String[]]$IPNetwork,
        
        [Parameter(Mandatory = $True,
                   Position = 1,
                   HelpMessage ="Specify the first IP in the range(s).")]
        [String]$StartIP,

        [Parameter(Mandatory = $True,
                   Position = 2,
                   HelpMessage ="Enter the last IP in the range(s).")]
        [String]$EndIP,

        [Parameter(Mandatory = $False,
        HelpMessage ="Set this if you want to include HostNames that could not be resolved.")]
        [Switch]$Full,

        [Parameter(Mandatory = $False,
        HelpMessage ="Set this if you wish to output the results of the scan to a text file.")]
        [Switch]$OutCSV

    )
    
    
    BEGIN {

    $Ping = New-Object System.Net.Networkinformation.Ping
    $ActiveIPs = New-Object System.Collections.Queue
    $IPQueue = New-Object System.Collections.Queue
    $HostList = New-Object System.Collections.Generic.List[System.Object]

    $Pool = [RunspaceFactory]::CreateRunspacePool(1, 4)
    $Pool.ApartmentState = "MTA"
    $Pool.Open()
    $Threads = @()

    if($OutCSV) {
        
        $OutPath = "C:\Users\clafleur\Documents\NetworkScan.csv"
        Remove-Item -Path $OutPath -Force -EA SilentlyContinue
        $FileHandle = New-Object System.IO.StreamWriter -Arg $OutPath
        $FileHandle.AutoFlush = $True
        
        }
   }    

    PROCESS {

        function Populate-Queue {

            for ($i = 0; $i -LT $IPNetwork.Count; $i++) {

                [int]$tempip = $StartIP

                while ($tempip -LE $EndIP){

                    $IPQueue.Enqueue($IPNetwork[$i] + "." + $tempip)

                    $tempip++

                }
            }
        }

        function Ping-Node($IPaddr) {
        echo $IPaddr
            #$NumIPs = $IPQueue.Count

            #for([Int]$i = 0; $i -LT $NumIPs; $i++){

                #$IP = $IPQueue.Dequeue()
                $Test = $Ping.Send($IPaddr, 1, .1)

                if($Test.Status -EQ 'Success'){
        
                    $ActiveIPs.Enqueue($IPaddr)

                }
            #}
        }

        function Get-Hostname {

        $NumHosts = $ActiveIPs.Count
        
        for([Int]$i = 0; $i -LT $NumHosts; $i++){

            $HostInfo = New-Object -TypeName PSObject

            try {
            
                $IP = $ActiveIPs.Dequeue()
                $HostN = [System.Net.DNS]::GetHostEntry("$IP")

                $HostInfo | Add-Member -Type NoteProperty -Name IPAddress -Value $IP -Force
                $HostInfo | Add-Member -Type NoteProperty -Name HostName -Value $HostN.HostName -Force

                }

            catch {

                $HostInfo | Add-Member -Type NoteProperty -Name IPAddress -Value $IP -Force
                $HostInfo | Add-Member -Type NoteProperty -Name HostName -Value 'Unknown' -Force

                }

            $HostList.Add($HostInfo)

            if ($OutCSV) {

                Output-CSV($IP, $HostN)

                }
            }
        }

        function Output-CSV ($IPaddr, $HostName) {

            $FileHandle.WriteLine("$IP, $HostN")

        }

        function Go-Fast {

            $NumIPs = $IPQueue.Count
            
            for ([int]$NumIPs; $NumIPs -GT 0; $NumIPs--) {

                $Temp = $IPQueue.Dequeue()
                echo $Temp
                $Container = {Ping-Node($Temp)}

                $RunSpaceObj = [PSCustomObject] @{
                    Runspace = [PowerShell]::Create()
                    #Invoker = $Null
                }

                $RunSpaceObj.Runspace.RunSpacePool = $Pool
                $RunSpaceObj.Runspace.AddScript($Container) | Out-Null
                #$RunSpaceObj.Invoker = $RunSpaceObj.Runspace.BeginInvoke()
                $Threads += @($RunSpaceObj)
            }

            foreach ($t in $Threads) {

                $t.Runspace.Dispose()

            }

            $Pool.Close()
            $Pool.Dispose()
        }
    }   
     
     END {

        Populate-Queue
        Go-Fast
        #Ping-Node("172.28.29.152")
        Get-Hostname

        if($OutCSV){

            $FileHandle.Flush()
            $FileHandle.Dispose()
            $FileHandle.Close()
        
        }
        
        return $HostList
        
        }
    }