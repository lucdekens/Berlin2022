#region PowerCLI cmdlets

Measure-Command -Expression {
  1..10 | ForEach-Object -Process {
    Get-VMHost | Get-ScsiLun | Select Name
  }
} | Select -ExpandProperty TotalSeconds
#endregion

#region Get-View 1
Measure-Command -Expression {
  1..10 | ForEach-Object -Process {
    Get-View -ViewType HostSystem -PipelineVariable esx |
    ForEach-Object -Process {
      $esx.Config.StorageDevice.ScsiLun |
      Select CanonicalName
    }
  }
} | Select-Object -ExpandProperty TotalSeconds
#endregion

#region Get-View 2
Measure-Command -Expression {
  1..10 | ForEach-Object -Process {
    Get-View -ViewType HostSystem -Property 'Config.StorageDevice.ScsiLun' -PipelineVariable esx |
    ForEach-Object -Process {
      $esx.Config.StorageDevice.ScsiLun |
      Select-Object CanonicalName
    }
  }
} | Select-Object -ExpandProperty TotalSeconds
#endregion

#region Parallel

Measure-Command -Expression {
  1..10 | ForEach-Object -Parallel {
    Get-View -ViewType HostSystem -Property 'Config.StorageDevice.ScsiLun' -Server $using:defaultviserver -PipelineVariable esx |
    ForEach-Object -Process {
      $esx.Config.StorageDevice.ScsiLun |
      Select-Object CanonicalName
    }
  }
} | Select-Object -ExpandProperty TotalSeconds
#endregion

#region Parallel and splatting

Measure-Command -Expression {
  1..10 | ForEach-Object -Parallel {
    $sView = @{
      ViewType = 'HostSystem'
      Property = 'Config.StorageDevice.ScsiLun'
      Server = $using:defaultviserver
      PipelineVariable = 'esx'
    }
    Get-View @sView  |
    ForEach-Object -Process {
      $esx.Config.StorageDevice.ScsiLun |
      Select-Object CanonicalName
    }
  }
} | Select-Object -ExpandProperty TotalSeconds
#endregion
