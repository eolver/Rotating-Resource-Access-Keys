# Rotating-Storage-Access-Keys
how to regenerate your access keys regularly using PowerShell in Azure. You are provided two access keys so that you can maintain connections using one key while regenerating the other.

In this example I will be rotating a storage account key, storing in a keyvault and directly calling that from a function app at runtime whilst rotating the keys every 15 minutes


1. Create a storage account
2. create a KeyVault
3. Create a keyvault (with MSI on)
4. Create a Automation Account
5. add the objectID of the function app to the keyvault to get secrets
6. Install az modules (az.accounts, az.storage, az.websites) from gallery on automation account
7. Create a runbook (Rotate-Storage-Keys-and-update-App)
8. Copy the powershell script shared in this repo
9. Update the variables $ResourceGroupName,$storageAccountName,$storageKeyNameToRotate, $keyvaultname,$webSiteName
10. Test that the rotation is working



