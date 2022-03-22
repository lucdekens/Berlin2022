# Exploring cmdlets
Get-Help -Name Get-VM

Get-Help -Name Get-VM -Parameter Tag

Get-Command -Name Get-VM -Syntax

# Object methods & properties
Get-VM -Name DC1 | Get-Member

# Object content
Get-VM -Name DC1 | Format-Custom -Depth 2 | more
Get-VM -Name DC1 | Format-Custom -Depth 2 | code -


# PowerCLI Cmdlet Reference
Start-Process -FilePath 'https://developer.vmware.com/docs/powercli/latest/products/'

# PowerCLI User's Guide
Start-Process -FilePath 'https://developer.vmware.com/docs/15166/'