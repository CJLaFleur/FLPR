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
    
    $IPQueue = New-Object System.Collections.Queue
    $Ping = New-Object System.Net.Networkinformation.Ping
    $ComputerList = New-Object System.Collections.Generic.List[System.Object]

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

                [int]$tempip =$StartIP

                while ($tempip -LE $EndIP){

                    $IPQueue.Enqueue($IPNetwork[$i] + "." + $tempip)

                    $tempip++

                }

            }

        }

        function Ping-Network {

            $NumIPs = $IPQueue.Count

            for([Int]$i = 0; $i -LT $NumIPs; $i++){
            
                $ComputerInfo = New-Object -TypeName PSObject
                $IP = $IPQueue.Dequeue()
                $Test = $Ping.Send($IP, 1, .1)
                
                if($Test.Status -EQ 'Success'){
                    
                    try{
                        
                        $HostN = [System.Net.DNS]::GetHostEntry("$IP")
                        $HostN = $HostN.HostName

                        for([Int]$j = 0; $j -LT $HostN.Length; $j++){
                            
                            if($HostN[$j] -EQ "."){
                            
                                [String] $Temp = $HostN.Substring(0, $j)
                                $HostN = $Temp
                            }
                        
                        }

                    $ComputerInfo | Add-Member -Type NoteProperty -Name IPAddress -Value $IP -Force
                    $ComputerInfo | Add-Member -Type NoteProperty -Name HostName -Value $HostN -Force

                    if($OutCSV){
                
                        $FileHandle.WriteLine("$IP, $HostN")
                    
                    }
                }
                
                    catch{
                    
                        if($Full){
                        
                            $ComputerInfo | Add-Member -Type NoteProperty -Name IPAddress -Value $IP -Force
                            $ComputerInfo | Add-Member -Type NoteProperty -Name HostName -Value 'HostName could not be resolved' -Force
                        
                        if($OutCSV){
                        
                            $FileHandle.WriteLine($ComputerInfo.IPAddress + ", " + $ComputerInfo.HostName)
                            
                            }
                        }
                    }
                
                    $ComputerList.Add($ComputerInfo)
             }
          
            else{
            
                Start-Sleep -Milliseconds .1
          }
        }
      }
    }
     
     END{

        Populate-Queue
        Ping-Network

        if($OutCSV){
            $FileHandle.Flush()
            $FileHandle.Dispose()
            $FileHandle.Close()
        }
        return $ComputerList
        }

    }