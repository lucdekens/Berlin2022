#Requires -Module @{ ModuleName = 'VMware.VimAutomation.Core'; ModuleVersion = '12.1' }

[CmdletBinding()]
param(
  [String]$ClusterName = '*'
)

$vms = Get-Cluster -Name $ClusterName | Get-VM

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