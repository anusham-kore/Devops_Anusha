# Azure CLI Deployment Guide


az group create `
    --name demo-rg `
    --location centralindia

az vm create `
    --resource-group demo-rg `
    --name devops-win-vm `
    --image Win2022Datacenter `
    --admin-username azureuser `
    --admin-password "YourStrongPassword@123" `
    --size Standard_D2s_v3

az vm open-port `
    --resource-group demo-rg `
    --name devops-win-vm `
    --port 3389
az vm show `
    --resource-group demo-rg `
    --name devops-win-vm `
    --show-details `
    --query publicIps `
    -o tsv

    20.198.89.211

This directory contains Azure CLI scripts to provision the same cloud infrastructure as the Terraform configuration, without using Terraform.

## Files

- **azure-cli-deploy.sh** - Bash script for macOS/Linux
- **azure-cli-deploy.ps1** - PowerShell script for Windows

## Prerequisites

1. **Azure CLI Installed**: Download from https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
2. **Azure Account**: Active Azure subscription with permissions to create resources
3. **Authenticated**: Run `az login` to authenticate before executing scripts

## Infrastructure Deployed

The scripts provision the following resources in **centralindia** region:

### Core Services
- **Resource Group**: devops-prod-rg-centralindia
- **Virtual Network**: devops-vnet (10.0.0.0/16)
- **Subnets**: 
  - AKS Subnet (10.0.1.0/24) - with AKS delegation
  - Application Gateway Subnet (10.0.2.0/24)
  - Database Subnet (10.0.3.0/24) - with PostgreSQL delegation

### Compute & Container
- **Azure Kubernetes Service (AKS)**
  - Name: devops-prod-aks-ci
  - Node Count: 3 (Standard_DS3_v2)
  - Autoscaling: 3-10 nodes
  - Features: Azure Policy, Azure Monitor, Azure AD integration, Managed Identity
  
- **Azure Container Registry (ACR)**
  - Name: devopsproductcrci
  - SKU: Premium
  - Admin access enabled

### Networking
- **Application Gateway** (WAF v2)
  - Name: devops-appgw
  - WAF Policy: OWASP 3.2
  - Capacity: 2 instances
  
- **NAT Gateway**
  - Name: aks-nat-gateway
  - Static Public IP for outbound traffic
  
- **Network Security Groups** (2)
  - aks-nsg: Allows traffic from App Gateway
  - appgw-nsg: HTTPS and gateway manager rules
  
- **DNS Zone**
  - Domain: anusha-devops-demo.com
  - API Endpoint: api.anusha-devops-demo.com

### Databases
- **PostgreSQL Flexible Servers** (3 instances)
  - user-db: User data
  - order-db: Order data  
  - payment-db: Payment data
  - SKU: Standard_B2s
  - Storage: 32 GB
  - Version: PostgreSQL 14
  - HA: Enabled
  - Geo-redundant backups: 30-day retention

### Monitoring & Logging
- **Log Analytics Workspace** (devops-law)
  - SKU: PerGB2018
  - Retention: 30 days

- **Application Insights** (devops-appinsights)
  - Type: Web
  - Linked to Log Analytics workspace

### Security & Storage
- **Key Vault** (devops-prod-kv-ci-anusha-anusha01)
  - SKU: Standard
  - Soft delete: 7 days
  - Purge protection: Enabled

- **Storage Account** (devopsprodstorage)
  - Type: StorageV2
  - Redundancy: Geo-redundant (GRS)
  - HTTPS-only: Enabled

## Usage

### For Windows (PowerShell)

```powershell
# Navigate to the terraform directory
cd D:\Anusha_Maddela\anusha_devops\Devops_Anusha\Azure_DevOps_Project

# Run the script
.\azure-cli-deploy.ps1
```

### For macOS/Linux (Bash)

```bash
# Navigate to the terraform directory
cd ~/your-path/Devops_Anusha/Azure_DevOps_Project

# Make script executable
chmod +x azure-cli-deploy.sh

# Run the script
./azure-cli-deploy.sh
```

## Configuration Variables

Edit these variables in the script before running to customize your deployment:

| Variable | Default | Purpose |
|----------|---------|---------|
| LOCATION | centralindia | Azure region |
| RESOURCE_GROUP | devops-prod-rg-centralindia | Resource group name |
| AKS_CLUSTER_NAME | devops-prod-aks-ci | Kubernetes cluster name |
| ACR_NAME | devopsproductcrci | Container registry name |
| DB_ADMIN_PASSWORD | P@ssw0rd123!Azure | PostgreSQL admin password |
| DNS_ZONE | anusha-devops-demo.com | Custom domain |

## Deployment Order

The scripts provision resources in this order:

1. Resource Group
2. Virtual Network & Subnets
3. Network Security Groups
4. Route Table
5. Public IPs
6. NAT Gateway
7. Container Registry
8. Log Analytics Workspace
9. Application Insights
10. Storage Account
11. Key Vault
12. PostgreSQL Databases (3x)
13. AKS Cluster
14. WAF Policy
15. Application Gateway
16. DNS Zone & Records

## Deployment Time

- **Typical Duration**: 15-30 minutes
- **Longest Operations**:
  - AKS Cluster Creation: ~10-15 minutes
  - PostgreSQL Servers: ~5-10 minutes each

## Output Information

After successful deployment, the script displays:

- ACR Login Server (for docker login)
- AKS Cluster Name
- Application Gateway Public IP
- DNS Zone nameservers
- Database FQDNs
- Key Vault URL
- Command to get AKS credentials

## Getting AKS Credentials

After deployment, connect to your AKS cluster:

```bash
az aks get-credentials \
  --resource-group devops-prod-rg-centralindia \
  --name devops-prod-aks-ci-ci \
  --overwrite-existing
```

Verify connection:
```bash
kubectl get nodes
kubectl get namespaces
```

## Logging into Container Registry

```bash
az acr login --name devopsproductcrci
```

Or with Docker credentials:
```bash
az acr credential show --resource-group devops-prod-rg-centralindia-centralindia --name devopsproductcrci
```

## Cleanup/Destruction

To delete all created resources:

```powershell
# PowerShell
az group delete --resource-group devops-prod-rg-centralindia --yes --no-wait
```

```bash
# Bash
az group delete --resource-group devops-prod-rg-centralindia --yes --no-wait
```

**Note**: The `--no-wait` flag returns immediately without waiting for completion. Remove it to wait for deletion.

## Troubleshooting

### Error: "The subscription is not registered to use namespace"
```powershell
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.Insights
```

### Error: "Location is not available"
Verify centralindia supports your required services or change LOCATION variable:
```powershell
az account list-locations --query "[].displayName"
```

### Error: "Quota exceeded"
Some regions may have subscription quotas. Try a different location:
- East US 2: eastus2
- South Central US: southcentralus  
- North Europe: northeurope

### Check Deployment Status

```bash
# List all resources in resource group
az resource list --resource-group devops-prod-rg-centralindia

# Check specific resource
az aks show --resource-group devops-prod-rg-centralindia --name devops-prod-aks-ci
```

## Comparison: Azure CLI vs Terraform

| Aspect | Azure CLI | Terraform |
|--------|-----------|-----------|
| **State Management** | Manual | Automated |
| **Idempotency** | Limited | Full |
| **Code as Infrastructure** | Yes | Yes (HCL) |
| **Complexity** | Linear script | Declarative |
| **Modifications** | Manual commands | Plan & apply |
| **Multi-cloud** | Azure only | Multi-cloud |
| **Team Collaboration** | Harder | Easier |

## Best Practices

1. **Version Control**: Keep scripts in Git
2. **Parameter Files**: Consider using external JSON for variables
3. **Error Handling**: Scripts include error checking with `set -e`
4. **Logging**: Timestamps added to each operation
5. **Documentation**: Update variables section before sharing

## Additional Commands

### Monitor AKS deployment progress
```bash
az aks show --resource-group devops-prod-rg-centralindia --name devops-prod-aks-ci -o json
```

### Get PostgreSQL connection details
```bash
az postgres flexible-server show \
  --resource-group devops-prod-rg-centralindia \
  --name user-db \
  --query fullyQualifiedDomainName
```

### Configure DNS delegation
```bash
# Get nameservers
az network dns zone show \
  --resource-group devops-prod-rg-centralindia \
  --name anusha-devops-demo.com \
  --query nameServers
```

## Support & Documentation

- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [AKS Best Practices](https://learn.microsoft.com/en-us/azure/aks/best-practices)
- [PostgreSQL Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/)
- [Application Gateway WAF](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview)

## License

DevOps Infrastructure as Code - Azure CLI Version
