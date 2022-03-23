#$vmName = 'PhotonV3Rev3'
$vmName = 'PhotonV4Rev2'
$user = 'root'

# Convert Template to VM and start

Get-Template -Name $vmName |
Set-Template -ToVM -Confirm:$false |
Start-VM -VM $vmName | Out-Null

# Wait till VMware Tools are ready to accept commands

While(-not (Get-VM -Name $vmName).ExtensionData.Guest.GuestOperationsReady){
  Start-Sleep -Seconds 5
}

# Get credentials

$vm = Get-VM -Name $vmName
$viCred = Get-VICredentialStoreItem -Host $vmName -User $user
$cred = New-Object -TypeName PSCredential -ArgumentList $user,(ConvertTo-SecureString -String $viCred.Password -AsPlainText -Force)

# See KB74880

$code1 = @'
vmware-toolbox-cmd config get deployPkg enable-custom-scripts
'@
$code2 = @'
vmware-toolbox-cmd config set deployPkg enable-custom-scripts true
'@

$sInvoke = @{
  VM = $vm
  GuestCredential = $cred
  ScriptType = 'Bash'
  ScriptText = $code1
}
$result = Invoke-VMScript @sInvoke

# Default setting
# [deployPkg] enable-custom-scripts UNSET

If($result.ScriptOutput -match 'UNSET'){
  $sInvoke.ScriptText = $code2
  $result = Invoke-VMScript @sInvoke

  $sInvoke.ScriptText = $code1
  $result = Invoke-VMScript @sInvoke

  # If all is well, convert back to Template

  if ($result.ScriptOutput -match '\[deployPkg\] enable-custom-scripts = true'){
    Shutdown-VMGuest -VM $vm -Confirm:$false
    while((Get-VM -Name $vmName).PowerState -ne 'PoweredOff'){
      Start-Sleep -Seconds 5
    }
    Set-VM -VM $vm -ToTemplate -Confirm:$false | Out-Null
  }
}