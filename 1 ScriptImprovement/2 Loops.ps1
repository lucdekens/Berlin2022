#region Method 1

foreach ($vm in Get-VM){
  $vm | Select Name,NumCpu
}
#endregion

#region Method 1 - Empty pipeline

foreach ($vm in Get-VM) {
  $vm | Select-Object Name, NumCpu
} | Export-Csv -Path .\report.csv -NoTypeInformation -UseCulture
#endregion

#region Method 1 - Awkward fix for Empty pipeline

$report = foreach ($vm in Get-VM) {
  $vm | Select-Object Name, NumCpu
}
$report | Export-Csv -Path .\report.csv -NoTypeInformation -UseCulture
Invoke-Item -Path .\report.csv
#endregion

#region Method 1 - Use the pipeline

Get-VM |
Select-Object Name, NumCpu |
Export-Csv -Path .\report.csv -NoTypeInformation -UseCulture
Invoke-Item -Path .\report.csv
#endregion

#region Method 2 - Nested loops

$report = foreach($vmhost in Get-VMHost){
  foreach($ds in Get-Datastore -RelatedObject $vmhost){
    '' | Select @{N = 'VMHost'; E = { $vmhost.Name } },@{N='Name';E={$ds.Name}}
  }
}
$report | Export-Csv -Path .\report.csv -NoTypeInformation -UseCulture
Invoke-Item -Path .\report.csv
#endregion

#region Foreach-Object

Get-VMHost |  ForEach-Object -Process {
  $vmhost = $_
  Get-Datastore -RelatedObject $vmhost |
  Select @{N='VMHost';E={$vmhost.Name}},Name
} | Export-Csv -Path .\report1.csv -NoTypeInformation -UseCulture
Invoke-Item -Path .\report1.csv
#endregion

#region PipelineVariable + Use the pipeline

Get-VMHost -PipelineVariable vmhost |
Get-Datastore |
Select-Object @{N = 'VMHost'; E = { $vmhost.Name } }, Name |
Export-Csv -Path .\report2.csv -NoTypeInformation -UseCulture
Invoke-Item -Path .\report2.csv
#endregion

#region Oops, correction

Get-VMHost -PipelineVariable vmhost |
ForEach-Object -Process {
  Get-Datastore -RelatedObject $vmhost |
  Select-Object @{N = 'VMHost'; E = { $vmhost.Name } }, Name
 } | Export-Csv -Path .\report3.csv -NoTypeInformation -UseCulture
Invoke-Item -Path .\report3.csv
#endregion