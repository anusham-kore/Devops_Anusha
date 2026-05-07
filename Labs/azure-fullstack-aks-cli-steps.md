# Azure Full-Stack AKS Project - Azure CLI Steps

This file creates the CloudShop practice environment using Azure CLI in one resource group: `rg-cloudshop-dev`.

Use this for a short 1-hour lab, then delete the resource group to stop charges.

## Cost-Saving Lab Design

| Area | Lab Choice |
| --- | --- |
| Resource group | `rg-cloudshop-dev` |
| Region | `Central India` |
| AKS tier | Free tier |
| AKS node count | 1 node |
| AKS VM size | `Standard_B2s` |
| ACR SKU | Basic |
| SQL Database | Basic |
| Queue | Storage Queue |
| Ingress | Simple LoadBalancer service |
| Application Gateway | Skip for this lab |

## 1. Login

```powershell
az login
az account show --output table
```

If needed, select the correct subscription:

```powershell
az account set --subscription "<subscription-id-or-name>"
```

## 2. Set Variables

```powershell
$RG="rg-cloudshop-dev"
$LOC="centralindia"
$VNET="vnet-cloudshop-dev-cin"
$AKS_SUBNET="snet-aks"
$ACR="acrcloudshopdevcin001"
$AKS="aks-cloudshop-dev-cin"
$AKS_VM_SIZE="Standard_B2als_v2"
$STORAGE="stcloudshopdevcin001"
$SQLSERVER="sql-cloudshop-dev-cin"
$SQLDB="sqldb-cloudshop-dev"
$KV="kv-cloudshop-dev-cin"
$LAW="law-cloudshop-dev-cin"
$SQL_ADMIN="sqladminuser"
$SQL_PASSWORD="Newchange@123"
```

Change `$SQL_PASSWORD` before running the SQL commands.

## 3. Create Resource Group

```powershell
az group create `
  --name $RG `
  --location $LOC `
  --tags Environment=Dev Project=CloudShop Owner=Anusha CostCenter=Learning
```

## 4. Create Virtual Network

```powershell
az network vnet create `
  --resource-group $RG `
  --name $VNET `
  --location $LOC `
  --address-prefix 10.40.0.0/16 `
  --subnet-name $AKS_SUBNET `
  --subnet-prefix 10.40.1.0/24
```

## 5. Create Azure Container Registry

```powershell
az acr create `
  --resource-group $RG `
  --name $ACR `
  --location $LOC `
  --sku Basic
```

## 6. Create AKS Cluster

```powershell
az aks create `
  --resource-group $RG `
  --name $AKS `
  --location $LOC `
  --node-count 1 `
  --node-vm-size $AKS_VM_SIZE `
  --enable-managed-identity `
  --attach-acr $ACR `
  --generate-ssh-keys
```
az aks show `
  --resource-group $RG `
  --name $AKS `
  --query "identityProfile.kubeletidentity.clientId" `
  --output table

az role assignment list `
  --assignee $(az aks show --resource-group $RG --name $AKS --query "identityProfile.kubeletidentity.objectId" -o tsv) `
  --scope $(az acr show --name $ACR --resource-group $RG --query id -o tsv) `
  --output table


Get AKS credentials:

```powershell
az aks get-credentials `
  --resource-group $RG `
  --name $AKS
```

Verify node status:

```powershell
kubectl get nodes
```

## 7. Create Storage Account

```powershell
az storage account create `
  --resource-group $RG `
  --name $STORAGE `
  --location $LOC `
  --sku Standard_LRS `
  --kind StorageV2
```

Create Blob containers:

```powershell
az storage container create --account-name $STORAGE --name product-images --auth-mode login
az storage container create --account-name $STORAGE --name receipts --auth-mode login
az storage container create --account-name $STORAGE --name logs-archive --auth-mode login
```

Create Storage Queue:

```powershell
az storage queue create `
  --account-name $STORAGE `
  --name orders-to-process `
  --auth-mode login
```

## 8. Create Azure SQL Database

Create SQL server:

```powershell
az sql server create `
  --resource-group $RG `
  --name $SQLSERVER `
  --location $LOC `
  --admin-user $SQL_ADMIN `
  --admin-password $SQL_PASSWORD
```
(MissingSubscriptionRegistration) The subscription is not registered to use namespace 'Microsoft.Sql'. 

Run this first:

az provider register --namespace Microsoft.Sql
Then check status:

az provider show `
  --namespace Microsoft.Sql `
  --query registrationState `
  --output tsv
Wait until it shows:

Registered
Then rerun your SQL Server create command:
az sql server create `
  --resource-group $RG `
  --name $SQLSERVER `
  --location $LOC `
  --admin-user $SQL_ADMIN `
  --admin-password $SQL_PASSWORD

Allow Azure services for quick lab connectivity:

```powershell
az sql server firewall-rule create `
  --resource-group $RG `
  --server $SQLSERVER `
  --name AllowAzureServices `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 0.0.0.0
```

Create Basic SQL database:

```powershell
az sql db create `
  --resource-group $RG `
  --server $SQLSERVER `
  --name $SQLDB `
  --service-objective Basic
```
(MissingSubscriptionRegistration) The subscription is not registered to use namespace 'Microsoft.KeyVault'. 

Same type of issue: your subscription has not registered the Key Vault provider yet.

Run:

az provider register --namespace Microsoft.KeyVault
Check status:

az provider show `
  --namespace Microsoft.KeyVault `
  --query registrationState `
  --output tsv
Wait until it shows:

Registered

## 9. Create Key Vault

```powershell
az keyvault create `
  --resource-group $RG `
  --name $KV `
  --location $LOC
```
Your Key Vault exists, but your logged-in user does not have permission to create secrets.

Run this:

$SIGNED_IN_USER_ID = az ad signed-in-user show --query id -o tsv
$KV_ID = az keyvault show --name $KV --resource-group $RG --query id -o tsv

az role assignment create `
  --assignee-object-id $SIGNED_IN_USER_ID `
  --assignee-principal-type User `
  --role "Key Vault Secrets Officer" `
  --scope $KV_ID
  
Store SQL connection string:

```powershell
az keyvault secret set `
  --vault-name $KV `
  --name SqlConnectionString `
  --value "Server=tcp:$SQLSERVER.database.windows.net,1433;Database=$SQLDB;User ID=$SQL_ADMIN;Password=$SQL_PASSWORD;Encrypt=true;"
```

## 10. Create Log Analytics Workspace

```powershell
az monitor log-analytics workspace create `
  --resource-group $RG `
  --workspace-name $LAW `
  --location $LOC
```

For a short lab, keep logging light and delete the resource group after practice.

## 11. Deploy Simple Test App

Create namespace:

```powershell
kubectl create namespace cloudshop-dev
```

Deploy `nginx`:

```powershell
kubectl create deployment cloudshop-test `
  --image=nginx `
  --namespace cloudshop-dev
```

Expose it using a public load balancer:

```powershell
kubectl expose deployment cloudshop-test `
  --type=LoadBalancer `
  --port=80 `
  --namespace cloudshop-dev
```

Check external IP:

```powershell
kubectl get svc -n cloudshop-dev
```

Open the `EXTERNAL-IP` in a browser after it appears.
NAME             TYPE           CLUSTER-IP   EXTERNAL-IP      PORT(S)        AGE
cloudshop-test   LoadBalancer   10.0.65.43   20.219.241.104   80:30564/TCP   24s

## 12. Verify Resources

```powershell
az resource list `
  --resource-group $RG `
  --output table
```
Name                                       ResourceGroup     Location      Type                                        Status
-----------------------------------------  ----------------  ------------  ------------------------------------------  ---------
vnet-cloudshop-dev-cin                     rg-cloudshop-dev  centralindia  Microsoft.Network/virtualNetworks           Succeeded
acrcloudshopdevcin001                      rg-cloudshop-dev  centralindia  Microsoft.ContainerRegistry/registries      Succeeded
aks-cloudshop-dev-cin                      rg-cloudshop-dev  centralindia  Microsoft.ContainerService/managedClusters  Succeeded
stcloudshopdevcin001                       rg-cloudshop-dev  centralindia  Microsoft.Storage/storageAccounts           Succeeded
sql-cloudshop-dev-cin                      rg-cloudshop-dev  centralindia  Microsoft.Sql/servers                       Succeeded
sql-cloudshop-dev-cin/master               rg-cloudshop-dev  centralindia  Microsoft.Sql/servers/databases             Succeeded
sql-cloudshop-dev-cin/sqldb-cloudshop-dev  rg-cloudshop-dev  centralindia  Microsoft.Sql/servers/databases             Succeeded
kv-cloudshop-dev-cin                       rg-cloudshop-dev  centralindia  Microsoft.KeyVault/vaults                   Succeeded
law-cloudshop-dev-cin                      rg-cloudshop-dev  centralindia  Microsoft.OperationalInsights/workspaces    Succeeded

```powershell
kubectl get all -n cloudshop-dev
```

## 13. Delete Everything After 1 Hour

Delete the full resource group to stop charges:

```powershell
az group delete `
  --name $RG `
  --yes `
  --no-wait
```

Check whether the resource group is gone:

```powershell
az group exists --name $RG
```

If the output is `false`, the resource group has been deleted.

## Interview Explanation

I created a full-stack Azure practice environment using Azure CLI in one resource group. The environment included AKS, ACR, Azure SQL Database, Storage Account, Storage Queue, Key Vault, VNet, and Log Analytics. I deployed a simple container workload to AKS and exposed it using a LoadBalancer service. After testing, I deleted the resource group to stop cost.
