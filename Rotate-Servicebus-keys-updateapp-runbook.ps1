$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzAccount -ServicePrincipal -Tenant $Conn.TenantID `
-ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint -Subscription $Conn.SubscriptionId 

$ResourceGroupName="<Resource Group Name>"
$keyvaultname="<Keyvault Name Here>"
$webSiteName="<App Name Here>"

$namespace="<Servicebus Namespace Name>"
$Topicqueuename="<Topic or Queue Name>"
$policyname="<Shared Access Policy>"

$policy=Get-AzServiceBusKey -ResourceGroupName $ResourceGroupName -Queue $Topicqueuename -Namespace $namespace -Name $policyname

$connectionstring = "Endpoint=sb://"+$namespace+".servicebus.windows.net/;SharedAccessKeyName="+$policyname+";SharedAccessKey="+$policy.SecondaryKey+";"
  $Secret = ConvertTo-SecureString -String $connectionstring -AsPlainText -Force
  $newsecret=Set-AzKeyVaultSecret -VaultName $keyvaultname -Name 'servicebuskey' -SecretValue $Secret
  


Write-Output "Keyvault Secret Updated with secondary key"

  
 #This code retains webapp appsettings 


$app=Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $webSiteName



$newAppSettings=@{}

$appsettings=$app.SiteConfig.AppSettings 


foreach($appsetting in $appsettings)
{

$val=$appsetting.Value

$newAppSettings +=@{$appsetting.Name="$val"}

}

$newAppSettings.EventHubKey = "@Microsoft.KeyVault(SecretUri="+$newsecret.Id+")";



Set-AzWebApp -ResourceGroupName $resourceGroupName -Name $webSiteName -AppSettings $newAppSettings -ErrorAction SilentlyContinue


Write-Output "App Setting secret uri Updated with secondary Key"

start-sleep -Seconds 30


New-AzServiceBusKey `
-ResourceGroupName $ResourceGroupName `
-RegenerateKey PrimaryKey `
-Namespace $namespace `
-Queue $Topicqueuename `
-Name $policyname


Write-Output "Primary Key Refreshed"

$policy=Get-AzServiceBusKey -ResourceGroupName $ResourceGroupName -Queue $Topicqueuename -Namespace $namespace -Name $policyname

$connectionstring = "Endpoint=sb://"+$namespace+".servicebus.windows.net/;SharedAccessKeyName="+$policyname+";SharedAccessKey="+$policy.PrimaryKey+";"
  $Secret = ConvertTo-SecureString -String $connectionstring -AsPlainText -Force
  $newsecret=Set-AzKeyVaultSecret -VaultName $keyvaultname -Name 'servicebuskey' -SecretValue $Secret
  
Write-Output "Keyvault Secret Updated With Primary"

#This code retains webapp appsettings 


$app=Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $webSiteName



$newAppSettings=@{}

$appsettings=$app.SiteConfig.AppSettings 


foreach($appsetting in $appsettings)
{

$val=$appsetting.Value

$newAppSettings +=@{$appsetting.Name="$val"}

}

$newAppSettings.ServicebusKey = "@Microsoft.KeyVault(SecretUri="+$newsecret.Id+")";


Set-AzWebApp -ResourceGroupName $resourceGroupName -Name $webSiteName -AppSettings $newAppSettings -ErrorAction SilentlyContinue


Write-Output "App Setting secret uri Updated"


New-AzServiceBusKey `
-ResourceGroupName $ResourceGroupName `
-RegenerateKey SecondaryKey `
-Namespace $namespace `
-Queue $Topicqueuename `
-Name $policyname
Write-Output "Secondary Key Refreshed" 
 
