Get-VM -Name DC1 | Get-NetworkAdapter | Remove-NetworkAdapter -Confirm:$false
