# A short overview of the different methods that can be used to call a REST API from PS


#region Sample call
Start-Process -FilePath 'https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/system_config/deployment_type/'
#endregion

#region Getting the credentials

$viCred = Get-VICredentialStoreItem -Host $global:DefaultVIServer.Name -User 'administrator*'
$user = $viCred.User
$pswd = $viCred.Password
$vCenterName = $viCred.Host
#endregion

#region PS native

#region Authenticate

$encoded = [System.Text.Encoding]::UTF8.GetBytes(($user, $pswd -Join ':'))
$encodedPassword = [System.Convert]::ToBase64String($Encoded)
$authHeader = @{
  Authorization = “Basic $($EncodedPassword)”
}
$sRest = @{
  Method = 'Post'
  Uri = "https://$($vCenterName)/rest/com/vmware/cis/session"
  Headers = $authHeader
}
$result = Invoke-RestMethod @sRest

$authHeader = @{
  'vmware-api-session-id' = $result.value
}
#endregion

#region WebRequest

$uri = "https://$($vCenterName)/api/vcenter/system-config/deployment-type"
$sRest = @{
  Uri = $uri
  Method = 'Get'
  Headers = $authHeader
}
$resultWeb = Invoke-WebRequest @sRest
$resultWeb
#endregion

#region RestMethod

$resultRest = Invoke-RestMethod @sRest
$resultRest
#endregion
#endregion

#region CisServices

Connect-CisServer -Server $viCred.Host -User $viCred.User -Password $viCred.Password
$deploy = Get-CisService -Name "com.vmware.vcenter.system_config.deployment_type"
$deploy.get() | Format-Custom
#endregion

#region Auto-generated cmdlets

Invoke-GetSystemConfigDeploymentType

Get-Module -Name 'VMware.Sdk*' -ListAvailable

#endregion
