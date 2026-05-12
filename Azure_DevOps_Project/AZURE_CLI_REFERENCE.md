# Azure CLI Quick Reference - DevOps Infrastructure

## Quick Setup

```powershell
# Authenticate to Azure
az login

# Set default subscription
az account set --subscription "7422b24d-7e25-4d81-973e-026bf89924c2"

# Verify subscription
az account show
```

## Resource Group Commands

```bash
# List all resource groups
az group list --output table

# Show specific resource group
az group show --name devops-prod-rg-centralindia --output json

# Delete resource group (and all resources)
az group delete --resource-group devops-prod-rg-centralindia --yes --no-wait

# List resources in resource group
az resource list --resource-group devops-prod-rg-centralindia --output table
```

## AKS Cluster Commands

```bash
# Get AKS cluster info
az aks show --resource-group devops-prod-rg-centralindia --name devops-prod-aks-ci

# Get credentials for kubectl
az aks get-credentials --resource-group devops-prod-rg-centralindia --name devops-prod-aks-ci

# List node pools
az aks nodepool list --resource-group devops-prod-rg-centralindia --cluster-name devops-prod-aks-ci

# Scale cluster
az aks scale --resource-group devops-prod-rg-centralindia --name devops-prod-aks-ci --node-count 5

# Enable cluster autoscaling
az aks nodepool update --resource-group devops-prod-rg-centralindia --cluster-name devops-prod-aks-ci --name nodepool1 --enable-cluster-autoscaling --min-count 1 --max-count 10

# Get cluster versions
az aks get-versions --location centralindia

# Upgrade cluster
az aks upgrade --resource-group devops-prod-rg-centralindia --name devops-prod-aks-ci --kubernetes-version 1.28.0

# Check cluster addons
az aks show --resource-group devops-prod-rg-centralindia --name devops-prod-aks-ci --query addonProfiles

# Get AKS logs
az aks diagnostics get-diagnostics-data --resource-group devops-prod-rg-centralindia --name devops-prod-aks-ci
```

## Container Registry Commands

```bash
# Show ACR details
az acr show --resource-group devops-prod-rg-centralindia --name devopsproductcrci

# Login to ACR
az acr login --name devopsproductcrci

# Get ACR credentials
az acr credential show --resource-group devops-prod-rg-centralindia --name devopsproductcrci

# List images in ACR
az acr repository list --name devopsproductcrci

# Build image in ACR
az acr build --registry devopsproductcrci --image myapp:v1.0 .

# Create webhook
az acr webhook create --registry devopsproductcrci --name mywebhook --actions push --uri http://example.com/webhook

# Get ACR login server
az acr show --resource-group devops-prod-rg-centralindia --name devopsproductcrci --query loginServer
```

## PostgreSQL Commands

```bash
# List PostgreSQL servers
az postgres flexible-server list --resource-group devops-prod-rg-centralindia

# Show server details
az postgres flexible-server show --resource-group devops-prod-rg-centralindia --name user-db

# Get connection string
az postgres flexible-server show --resource-group devops-prod-rg-centralindia --name user-db --query fullyQualifiedDomainName

# List databases
az postgres flexible-server db list --resource-group devops-prod-rg-centralindia --server-name user-db

# Reset admin password
az postgres flexible-server update --resource-group devops-prod-rg-centralindia --name user-db --admin-password <new-password>

# Start/Stop server
az postgres flexible-server start --resource-group devops-prod-rg-centralindia --name user-db
az postgres flexible-server stop --resource-group devops-prod-rg-centralindia --name user-db

# Create database
az postgres flexible-server db create --resource-group devops-prod-rg-centralindia --server-name user-db --database-name newdb

# Backup management
az postgres flexible-server backup list --resource-group devops-prod-rg-centralindia --server-name user-db
az postgres flexible-server restore --resource-group devops-prod-rg-centralindia --backup-name <backup-id> --name <new-server-name>
```

## Networking Commands

```bash
# List virtual networks
az network vnet list --resource-group devops-prod-rg-centralindia

# List subnets
az network vnet subnet list --resource-group devops-prod-rg-centralindia --vnet-name devops-vnet

# List network security groups
az network nsg list --resource-group devops-prod-rg-centralindia

# Add NSG rule
az network nsg rule create --resource-group devops-prod-rg-centralindia --nsg-name aks-nsg --name AllowHTTP --priority 100 --destination-port-ranges 80 --access Allow --protocol Tcp

# List public IPs
az network public-ip list --resource-group devops-prod-rg-centralindia

# Get public IP details
az network public-ip show --resource-group devops-prod-rg-centralindia --name appgw-pip

# List network interfaces
az network nic list --resource-group devops-prod-rg-centralindia

# Update route table
az network route-table route create --resource-group devops-prod-rg-centralindia --route-table-name aks-route-table --name myroute --address-prefix 10.1.0.0/24 --next-hop-type VirtualNetworkGateway
```

## Application Gateway Commands

```bash
# Show Application Gateway
az network application-gateway show --resource-group devops-prod-rg-centralindia --name devops-appgw

# Start/Stop Application Gateway
az network application-gateway start --resource-group devops-prod-rg-centralindia --name devops-appgw
az network application-gateway stop --resource-group devops-prod-rg-centralindia --name devops-appgw

# List backend pools
az network application-gateway address-pool list --resource-group devops-prod-rg-centralindia --gateway-name devops-appgw

# Add backend pool
az network application-gateway address-pool create --resource-group devops-prod-rg-centralindia --gateway-name devops-appgw --name backendpool --servers 10.0.1.10 10.0.1.11

# Show WAF policy
az network application-gateway waf-policy show --resource-group devops-prod-rg-centralindia --name appgw-waf-policy

# Get Application Gateway public IP
az network public-ip show --resource-group devops-prod-rg-centralindia --name appgw-pip --query ipAddress
```

## DNS Commands

```bash
# List DNS zones
az network dns zone list --resource-group devops-prod-rg-centralindia

# Show DNS zone
az network dns zone show --resource-group devops-prod-rg-centralindia --name anusha-devops-demo.com

# Get nameservers
az network dns zone show --resource-group devops-prod-rg-centralindia --name anusha-devops-demo.com --query nameServers

# List DNS records
az network dns record-set list --resource-group devops-prod-rg-centralindia --zone-name anusha-devops-demo.com

# Show specific record
az network dns record-set a show --resource-group devops-prod-rg-centralindia --zone-name anusha-devops-demo.com --name api

# Add DNS record
az network dns record-set a add-record --resource-group devops-prod-rg-centralindia --zone-name anusha-devops-demo.com --record-set-name www --ipv4-address 20.51.1.1

# Delete DNS record
az network dns record-set a remove-record --resource-group devops-prod-rg-centralindia --zone-name anusha-devops-demo.com --record-set-name www --ipv4-address 20.51.1.1
```

## Key Vault Commands

```bash
# List Key Vaults
az keyvault list --resource-group devops-prod-rg-centralindia

# Show Key Vault
az keyvault show --resource-group devops-prod-rg-centralindia --name devops-prod-kv-ci-anusha-anusha01

# List keys
az keyvault key list --vault-name devops-prod-kv-ci-anusha-anusha01

# List secrets
az keyvault secret list --vault-name devops-prod-kv-ci-anusha-anusha01

# Set secret
az keyvault secret set --vault-name devops-prod-kv-ci-anusha-anusha01 --name MySecret --value MyValue

# Get secret
az keyvault secret show --vault-name devops-prod-kv-ci-anusha-anusha01 --name MySecret

# Create certificate
az keyvault certificate create --vault-name devops-prod-kv-ci-anusha-anusha01 --name MyCert --policy @policy.json

# Update access policy
az keyvault set-policy --vault-name devops-prod-kv-ci-anusha-anusha01 --object-id <object-id> --secret-permissions get list set
```

## Storage Account Commands

```bash
# List storage accounts
az storage account list --resource-group devops-prod-rg-centralindia

# Show storage account
az storage account show --resource-group devops-prod-rg-centralindia --name devopsprodstorage

# Get connection string
az storage account show-connection-string --resource-group devops-prod-rg-centralindia --name devopsprodstorage

# List containers
az storage container list --account-name devopsprodstorage

# Create container
az storage container create --account-name devopsprodstorage --name mycontainer

# Upload blob
az storage blob upload --account-name devopsprodstorage --container-name mycontainer --name myblob --file localfile.txt

# List blobs
az storage blob list --account-name devopsprodstorage --container-name mycontainer
```

## Monitoring & Logging Commands

```bash
# List Log Analytics workspaces
az monitor log-analytics workspace list --resource-group devops-prod-rg-centralindia

# Show workspace
az monitor log-analytics workspace show --resource-group devops-prod-rg-centralindia --workspace-name devops-law

# List Application Insights
az monitor app-insights component show --resource-group devops-prod-rg-centralindia --app devops-appinsights

# Query logs
az monitor log-analytics query --workspace devops-law --analytics-query "AzureActivity | take 10"

# Get metrics
az monitor metrics list-definitions --resource /subscriptions/7422b24d-7e25-4d81-973e-026bf89924c2/resourceGroups/devops-prod-rg-centralindia/providers/Microsoft.ContainerService/managedClusters/devops-prod-aks-ci

# Create alert rule
az monitor metrics alert create --resource-group devops-prod-rg-centralindia --name high-cpu --scopes /subscriptions/7422b24d-7e25-4d81-973e-026bf89924c2/resourceGroups/devops-prod-rg-centralindia/providers/Microsoft.ContainerService/managedClusters/devops-prod-aks-ci --condition "avg Percentage CPU > 80" --description "Alert when CPU > 80%"
```

## Kubectl Commands (After getting AKS credentials)

```bash
# Get nodes
kubectl get nodes
kubectl get nodes -o wide

# Get pods
kubectl get pods --all-namespaces
kubectl get pods -n default

# Get services
kubectl get svc --all-namespaces

# Describe pod
kubectl describe pod <pod-name> -n default

# View logs
kubectl logs <pod-name> -n default

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash

# Apply manifest
kubectl apply -f deployment.yaml

# Delete pod
kubectl delete pod <pod-name> -n default
```

## Useful PowerShell Aliases

```powershell
# Add to PowerShell profile
Set-Alias -Name azl -Value "az login"
Set-Alias -Name azrg -Value "az group list --output table"
Set-Alias -Name azaks -Value "az aks list --resource-group devops-prod-rg-centralindia"
Set-Alias -Name azkv -Value "az keyvault list --resource-group devops-prod-rg-centralindia"

# Profile location (edit with notepad $PROFILE)
C:\Users\<username>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

## Common Troubleshooting Commands

```bash
# Check Azure CLI version
az --version

# Check installed extensions
az extension list

# Update Azure CLI
az upgrade

# Clear local authentication cache
az logout

# Debug with verbose output
az <command> --debug

# Get help for command
az <command> --help

# List available locations for services
az account list-locations --output table

# Check provider registration status
az provider list --query "[?contains(namespace, 'Microsoft.Container')]"

# Register provider
az provider register --namespace Microsoft.ContainerService
```

## Environment Configuration

```bash
# Set default resource group
az config set defaults.group=devops-prod-rg-centralindia

# Set default location
az config set defaults.location=centralindia

# Show current configuration
az config list

# Clear configuration
az config unset defaults.group
```

## Output Formatting

```bash
# JSON output
az resource list --resource-group devops-prod-rg-centralindia --output json

# Table output
az resource list --resource-group devops-prod-rg-centralindia --output table

# TSV output (tab-separated values)
az resource list --resource-group devops-prod-rg-centralindia --output tsv

# YAML output
az resource list --resource-group devops-prod-rg-centralindia --output yaml

# Query output
az aks list --query "[].name" --output tsv
```

## Batch Operations

```bash
# Delete all resources matching pattern
az resource list --resource-group devops-prod-rg-centralindia --query "[?type=='Microsoft.Network/publicIPAddresses']" | jq -r '.[].id' | xargs -I {} az resource delete --ids {}

# Export resources to template
az group export --name devops-prod-rg-centralindia > template.json

# Validate template
az group validate --resource-group devops-prod-rg-centralindia --template-file template.json
```

## Tips

1. Use `--output json` for scripting, `--output table` for reading
2. Use `-g` as shorthand for `--resource-group`
3. Use `--query` to filter JSON output
4. Use `@file.json` to read parameters from JSON file
5. Add `--debug` for troubleshooting
6. Use `--no-wait` for long-running operations in scripts

For more help, run: `az --help` or visit https://learn.microsoft.com/en-us/cli/azure/
