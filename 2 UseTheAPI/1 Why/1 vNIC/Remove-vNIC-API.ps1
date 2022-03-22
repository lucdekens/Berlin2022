$vm = Get-VM -Name MyVM
$vnic = Get-networkadapter -VM $vm

$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$dev = New-Object VMware.Vim.VirtualDeviceConfigSpec
$dev.Operation = 'edit'
$dev.Device = $vnic.ExtensionData
$dev.Device.Connectable.Connected = $false

$spec.DeviceChange += $dev

$vm.ExtensionData.ReconfigVM($spec)