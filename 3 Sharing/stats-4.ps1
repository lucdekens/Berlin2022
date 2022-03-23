#Requires -Version 7
#Requires -Module @{ ModuleName = 'VMware.VimAutomation.Core'; ModuleVersion = '12.5' }

[CmdletBinding()]
param(
  [String]$ClusterName = '*'
)

$ErrorView = 'ConciseView'

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
  Write-Error -Message "$((Get-Error -Newest 1).Exception.Message)"
  exit -2
}

$errorVarName = 'statError'
Remove-Variable -Name $errorVarName -Confirm:$false -ErrorAction SilentlyContinue

$sStat = @{
  Entity = $vms
  Stat = 'cpu.usagemhz.average'
  Realtime = $true
  MaxSamples = 1
  Instance = ''
  ErrorAction = 'SilentlyContinue'
  ErrorVariable = "+$($errorVarName)"
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

Write-Output -InputObject "`nFailed to collect data for the following`n"
$statError.Exception.Message |
Select-String -Pattern '.+\"(\w+)\"\.' |
ForEach-Object -Process { $_.Matches.Groups[1].Value } |
Select-Object @{N = 'VM'; E = { $_ }}
