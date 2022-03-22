#region Implicit type casting

'2020-12-31' -lt (Get-Date '2021-01-01')
(Get-Date '2021-01-01').ToString()
(Get-Date '2021-01-01') -gt '2020-12-31'

[DateTime]'2020-12-31' -lt (Get-Date '2021-01-01')
#endregion

#region Arrays

Get-VM |
Select Name,@{N='HD';E={(Get-HardDisk -VM $_).Name}} |
Export-Excel -Path .\report.xlsx
Invoke-Item -Path .\report.xlsx
#endregion

#region Arrays and -join

Get-VM |
Select-Object Name, @{N = 'HD'; E = { (Get-HardDisk -VM $_).Name -join ',' } } |
Export-Excel -Path .\report.xlsx
Invoke-Item -Path .\report.xlsx
#endregion
