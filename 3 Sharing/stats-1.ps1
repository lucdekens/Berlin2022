# Switch to 1 Get-Stat call
# Errors for powered off VMs

$vms = Get-Cluster | Get-VM

$sStat = @{
  Entity = $vms
  Stat = 'cpu.usagemhz.average'
  Realtime = $true
  MaxSamples = 1
  Instance = ''
}
Get-Stat @sStat |
Group-Object -Property { $_.Entity.Name } |
ForEach-Object -Process {
  New-Object -TypeName PSObject -Property ([ordered]@{
      VM = $_.Name
      Time = $_.Group.Timestamp
      Value = $_.Group.Value
      Unit = $_.Group.Unit
    })
}