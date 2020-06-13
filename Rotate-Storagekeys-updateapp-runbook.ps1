$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzAccount -ServicePrincipal -Tenant $Conn.TenantID `
-ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint -Subscription $Conn.SubscriptionId 


$ResourceGroupName="<Resource Group Name>"
$storageAccountName="<Storage Account Name>"
$storageKeyNameToRotate="key1"
$keyvaultname="<Keyvault Name Here>"
$webSiteName="<App Name Here>"

$staconext= Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $storageAccountName 



 $password=(Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $storageAccountName)| Where-Object {$_.KeyName -eq "key2"}
  $connectionstring = "DefaultEndpointsProtocol=https;AccountName="+$staconext.StorageAccountName+";AccountKey="+$password.Value+";EndpointSuffix=core.windows.net"
  $Secret = ConvertTo-SecureString -String $connectionstring -AsPlainText -Force
  $newsecret=Set-AzKeyVaultSecret -VaultName $keyvaultname -Name 'storageprimarykey' -SecretValue $Secret
  


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

$newAppSettings.PrimaryStorageKey = "@Microsoft.KeyVault(SecretUri="+$newsecret.Id+")";



Set-AzWebApp -ResourceGroupName $resourceGroupName -Name $webSiteName -AppSettings $newAppSettings -ErrorAction SilentlyContinue


Write-Output "App Setting secret uri Updated"

start-sleep -Seconds 30


 New-AzStorageAccountKey `
    -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $storageAccountName `
    -KeyName $storageKeyNameToRotate
Write-Output "Primary Key Refreshed"

$password=(Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $storageAccountName)| Where-Object {$_.KeyName -eq "key1"}
  $connectionstring = "DefaultEndpointsProtocol=https;AccountName="+$staconext.StorageAccountName+";AccountKey="+$password.Value+";EndpointSuffix=core.windows.net"
  $Secret = ConvertTo-SecureString -String $connectionstring -AsPlainText -Force
  $newsecret=Set-AzKeyVaultSecret -VaultName $keyvaultname -Name 'storageprimarykey' -SecretValue $Secret
  
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

$newAppSettings.PrimaryStorageKey = "@Microsoft.KeyVault(SecretUri="+$newsecret.Id+")";


Set-AzWebApp -ResourceGroupName $resourceGroupName -Name $webSiteName -AppSettings $newAppSettings -ErrorAction SilentlyContinue


Write-Output "App Setting secret uri Updated"


 New-AzStorageAccountKey `
    -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $storageAccountName `
    -KeyName key2
Write-Output "Secondary Key Refreshed"
