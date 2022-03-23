#$templateName = 'PhotonV3Rev3'
$templateName = 'PhotonV4Rev2'
$dsName = 'vsanDatastore'
$clusterName = 'cluster'
$osCustName = 'PhotonCust'
$vmNamePrefix = 'VM'
$user = 'root'

1..2 | ForEach-Object -Process {
  $vmName = "$vmNamePrefix$_"

  # Cleanup

  Get-VM -Name $vmName  -ErrorAction SilentlyContinue -PipelineVariable vm |
  ForEach-Object -Process {
    if ($vm.PowerState -eq 'PoweredOn') {
      Stop-VM -VM $vm -Confirm:$false | Out-Null
    }
    Remove-VM -VM $vm -DeletePermanently -Confirm:$false | Out-Null
  }

  # Create VM

  $sVM = @{
    Name = $vmName
    Template = $templateName
    Datastore = $dsName
    ResourcePool = $clusterName
    OSCustomizationSpec = $osCustName
  }
  $vm = New-VM @sVM

  # Start VM

  Start-VM -VM $vm | Out-Null

  # Wait for OSCustomization to end
  do {
    Start-Sleep -Seconds 5
  } until(Get-VIEvent -Entity $vm -Start (Get-Date).AddMinutes(-1) |
    Where-Object { $_.GetType().Name -match 'CustomizationSucceeded' })

#region Extra for the impatient

  # Force vNIC info refresh (instead of 30 sec wait)

  $viCred = Get-VICredentialStoreItem -Host $templateName -User $user
  $cred = New-Object -TypeName PSCredential -ArgumentList $user, (ConvertTo-SecureString -String $viCred.Password -AsPlainText -Force)
  $sInvoke = @{
    VM = $vmName
    GuestCredential = $cred
    ScriptType = 'Bash'
    ScriptText = 'vmware-toolbox-cmd info update network'
  }
  Invoke-VMScript @sInvoke | Out-Null
#endregion

}