function Scan-Network {

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

        function Ping-Node {

            $NumIPs = $IPQueue.Count

            for([Int]$i = 0; $i -LT $NumIPs; $i++){

                $IP = $IPQueue.Dequeue()
                $Test = $Ping.Send($IP, 1, .1)

                if($Test.Status -EQ 'Success'){
        
                    $ActiveIPs.Enqueue($IP)

                }
            }
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
    }   
     
     END {

        Populate-Queue
        Ping-Node
        Get-Hostname

        if($OutCSV){

            $FileHandle.Flush()
            $FileHandle.Dispose()
            $FileHandle.Close()
        
        }
        
        return $HostList
        
        }
    }