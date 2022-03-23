#Requires -Version 7
#Requires -Module @{ ModuleName = 'VMware.VimAutomation.Core'; ModuleVersion = '12.5' }

<#
.SYNOPSIS
  This script retrieves the average CPU usage (in MHz) for all VMs in on or more clusters
.DESCRIPTION
  This script retrieves the current average CPU usage (in MHz) for all VMs in one or more cluster.
  VMs that do not have the the statistics available are reported at the end.
  The script exits with -1 when no connection to a vCenter is present.
  The script exits with -2 when the VMs in the cluster can not be retrieved
.PARAMETER ClusterName
  The name(s) of the cluster(s) for which the report shall be produced.
  The default is for all clusters
.EXAMPLE
  .\stats_final.ps1 -ClusterName cluster
#>

[CmdletBinding()]
param(
  [String]$ClusterName = '*'
)

$ErrorView = 'ConciseView'

if(-not $global:defaultVIServer){
  Write-Error -Message "$(Get-Date -Format 'yyyymmdd HH:mm:ss.fff') You are not connected to a vSphere Server"
  exit -1
}
try{
  $vms = Get-Cluster -Name $ClusterName -ErrorAction Stop | Get-VM
}
catch{
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
Group-Object -Property {$_.Entity.Name} |
ForEach-Object -Process {
    New-Object -TypeName PSObject -Property ([ordered]@{
      VM = $_.Name
      Time = $_.Group.Timestamp
      Value = $_.Group.Value
      Unit = $_.Group.Unit
    })
}

Write-Output -InputObject "`nFailed to collect statistical data for the following`n"
$statError.Exception.Message |
Select-String -Pattern '.+\"(\w+)\"\.' |
ForEach-Object -Process {$_.Matches.Groups[1].Value} |
Select-Object @{N='VM';E={$_}}
