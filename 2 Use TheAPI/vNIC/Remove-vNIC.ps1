Get-VM -Name MyVM | Get-NetworkAdapter | Remove-NetworkAdapter -Confirm:$false
