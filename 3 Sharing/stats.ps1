$vms = Get-Cluster | Get-VM

foreach($vm in $vms){
  Get-Stat -Entity $vm -Realtime -Stat 'cpu.usagemhz.average' `
    -MaxSamples 1 -Instance ''
}