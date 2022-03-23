#Requires -Module @{ ModuleName = 'VMware.VimAutomation.Core'; ModuleVersion = '12.1' }

[CmdletBinding()]
param(
  [String]$ClusterName = 'cluster'
)

if (-not $global:defaultVIServer)
{
  Write-Error -Message "$(Get-Date -Format 'yyyymmdd HH:mm:ss.fff') You are not connected to a vSphere Server"
  exit -1
}
try
{
  $vms = Get-Cluster -Name $ClusterName -ErrorAction Stop | Get-VM
}
catch
{
  Write-Error -Message "$($error[0].Exception.Message)"
  exit -2
}

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