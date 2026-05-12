# Azure CLI Infrastructure Deployment Script
# Region: centralindia
# Environment: prod

# ===========================================
# VARIABLES
# ===========================================

$SUBSCRIPTION_ID = "7422b24d-7e25-4d81-973e-026bf89924c2"
$TENANT_ID = "3e6cbd15-be1d-404c-b2c4-4a0f8ee054ac"

$LOCATION = "centralindia"
$ENVIRONMENT = "prod"

$RESOURCE_GROUP = "anusha-prod-rg-ci"

$VNET_NAME = "anusha-vnet-ci"
$VNET_CIDR = "10.0.0.0/16"

$AKS_SUBNET = "aks-subnet-ci"
$AKS_SUBNET_CIDR = "10.0.1.0/24"

$APPGW_SUBNET = "appgw-subnet-ci"
$APPGW_SUBNET_CIDR = "10.0.2.0/24"

$DB_SUBNET = "db-subnet-ci"
$DB_SUBNET_CIDR = "10.0.3.0/24"

$AKS_CLUSTER_NAME = "anusha-aks-ci"

$ACR_NAME = "anushaproductacrci"

$KEY_VAULT_NAME = "anusha-kv-ci-demo"

$APP_INSIGHTS_NAME = "anusha-appinsights-ci"

$LAW_NAME = "anusha-law-ci"

$STORAGE_ACCOUNT = "anushaprodstorageci"

$DNS_ZONE = "anusha-devops-demo.com"

$APPGW_NAME = "anusha-appgw-ci"

$WAF_POLICY_NAME = "anusha-waf-policy-ci"

$NAT_GATEWAY = "anusha-nat-gateway-ci"

$NAT_PIP = "anusha-nat-pip-ci"

$APPGW_PIP = "anusha-appgw-pip-ci"

# PostgreSQL Variables
$DB_ADMIN_USER = "psqladmin"
$DB_ADMIN_PASSWORD = "P@ssw0rd123!Azure"
$DB_SKU = "Standard_B1ms"
$DB_STORAGE_SIZE = 32

# ===========================================
# LOG FUNCTION
# ===========================================

function Log-Operation {
    param([string]$Message)

    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor Green
}

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Azure CLI Infrastructure Deployment" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# ===========================================
# 1. RESOURCE GROUP
# ===========================================

Log-Operation "Creating Resource Group..."

az group create `
    --name $RESOURCE_GROUP `
    --location $LOCATION

# ===========================================
# 2. VIRTUAL NETWORK
# ===========================================

Log-Operation "Creating Virtual Network..."

az network vnet create `
    --resource-group $RESOURCE_GROUP `
    --name $VNET_NAME `
    --address-prefix $VNET_CIDR `
    --location $LOCATION

# ===========================================
# 3. SUBNETS
# ===========================================

Log-Operation "Creating AKS Subnet..."

az network vnet subnet create `
    --resource-group $RESOURCE_GROUP `
    --vnet-name $VNET_NAME `
    --name $AKS_SUBNET `
    --address-prefix $AKS_SUBNET_CIDR

Log-Operation "Creating Application Gateway Subnet..."

az network vnet subnet create `
    --resource-group $RESOURCE_GROUP `
    --vnet-name $VNET_NAME `
    --name $APPGW_SUBNET `
    --address-prefix $APPGW_SUBNET_CIDR

Log-Operation "Creating Database Subnet..."

az network vnet subnet create `
    --resource-group $RESOURCE_GROUP `
    --vnet-name $VNET_NAME `
    --name $DB_SUBNET `
    --address-prefix $DB_SUBNET_CIDR `
    --delegations Microsoft.DBforPostgreSQL/flexibleServers

# ===========================================
# 4. NETWORK SECURITY GROUPS
# ===========================================

Log-Operation "Creating AKS NSG..."

az network nsg create `
    --resource-group $RESOURCE_GROUP `
    --name "aks-nsg-ci" `
    --location $LOCATION

az network nsg rule create `
    --resource-group $RESOURCE_GROUP `
    --nsg-name "aks-nsg-ci" `
    --name "AllowAppGWInbound" `
    --priority 100 `
    --direction Inbound `
    --access Allow `
    --protocol Tcp `
    --source-address-prefixes "10.0.2.0/24" `
    --destination-address-prefixes "*" `
    --destination-port-ranges "*"

Log-Operation "Creating App Gateway NSG..."

az network nsg create `
    --resource-group $RESOURCE_GROUP `
    --name "appgw-nsg-ci" `
    --location $LOCATION

az network nsg rule create `
    --resource-group $RESOURCE_GROUP `
    --nsg-name "appgw-nsg-ci" `
    --name "AllowHTTPSInbound" `
    --priority 101 `
    --direction Inbound `
    --access Allow `
    --protocol Tcp `
    --source-address-prefixes "*" `
    --destination-address-prefixes "*" `
    --destination-port-ranges "443"

# ===========================================
# 5. PUBLIC IPS
# ===========================================

Log-Operation "Creating NAT Public IP..."

az network public-ip create `
    --resource-group $RESOURCE_GROUP `
    --name $NAT_PIP `
    --location $LOCATION `
    --sku Standard `
    --allocation-method Static

Log-Operation "Creating App Gateway Public IP..."

az network public-ip create `
    --resource-group $RESOURCE_GROUP `
    --name $APPGW_PIP `
    --location $LOCATION `
    --sku Standard `
    --allocation-method Static

# ===========================================
# 6. NAT GATEWAY
# ===========================================

Log-Operation "Creating NAT Gateway..."

az network nat gateway create `
    --resource-group $RESOURCE_GROUP `
    --name $NAT_GATEWAY `
    --location $LOCATION `
    --public-ip-address $NAT_PIP `
    --idle-timeout 10

Log-Operation "Associating NAT Gateway..."

az network vnet subnet update `
    --resource-group $RESOURCE_GROUP `
    --vnet-name $VNET_NAME `
    --name $AKS_SUBNET `
    --nat-gateway $NAT_GATEWAY

# ===========================================
# 7. ACR
# ===========================================

Log-Operation "Creating Azure Container Registry..."

az acr create `
    --resource-group $RESOURCE_GROUP `
    --name $ACR_NAME `
    --location $LOCATION `
    --sku Premium `
    --admin-enabled true

# ===========================================
# 8. LOG ANALYTICS
# ===========================================

Log-Operation "Creating Log Analytics Workspace..."

$LAW_ID = az monitor log-analytics workspace create `
    --resource-group $RESOURCE_GROUP `
    --workspace-name $LAW_NAME `
    --location $LOCATION `
    --sku PerGB2018 `
    --retention-time 30 `
    --query id -o tsv

# ===========================================
# 9. APPLICATION INSIGHTS
# ===========================================

Log-Operation "Creating Application Insights..."

az monitor app-insights component create `
    --app $APP_INSIGHTS_NAME `
    --location $LOCATION `
    --resource-group $RESOURCE_GROUP `
    --application-type web `
    --workspace $LAW_ID

# ===========================================
# 10. STORAGE ACCOUNT
# ===========================================

Log-Operation "Creating Storage Account..."

az storage account create `
    --resource-group $RESOURCE_GROUP `
    --name $STORAGE_ACCOUNT `
    --location $LOCATION `
    --sku Standard_GRS `
    --kind StorageV2 `
    --https-only true

# ===========================================
# 11. KEY VAULT
# ===========================================

Log-Operation "Creating Key Vault..."

az keyvault create `
    --resource-group $RESOURCE_GROUP `
    --name $KEY_VAULT_NAME `
    --location $LOCATION `
    --sku standard `
    --retention-days 7 `
    --enable-purge-protection true

# ===========================================
# 12. POSTGRESQL
# ===========================================

Log-Operation "Creating user-db-ci..."

az postgres flexible-server create `
    --resource-group $RESOURCE_GROUP `
    --name "user-db-ci" `
    --location $LOCATION `
    --tier Burstable `
    --admin-user $DB_ADMIN_USER `
    --admin-password $DB_ADMIN_PASSWORD `
    --sku-name $DB_SKU `
    --storage-size $DB_STORAGE_SIZE `
    --version 14 `
    --backup-retention 30 `
    --vnet $VNET_NAME `
    --subnet $DB_SUBNET

az postgres flexible-server db create `
    --resource-group $RESOURCE_GROUP `
    --server-name "user-db-ci" `
    --name "user_db"

Log-Operation "Creating order-db-ci..."

az postgres flexible-server create `
    --resource-group $RESOURCE_GROUP `
    --name "order-db-ci" `
    --location $LOCATION `
    --tier Burstable `
    --admin-user $DB_ADMIN_USER `
    --admin-password $DB_ADMIN_PASSWORD `
    --sku-name $DB_SKU `
    --storage-size $DB_STORAGE_SIZE `
    --version 14 `
    --backup-retention 30 `
    --vnet $VNET_NAME `
    --subnet $DB_SUBNET

az postgres flexible-server db create `
    --resource-group $RESOURCE_GROUP `
    --server-name "order-db-ci" `
    --name "order_db"

Log-Operation "Creating payment-db-ci..."

az postgres flexible-server create `
    --resource-group $RESOURCE_GROUP `
    --name "payment-db-ci" `
    --location $LOCATION `
    --tier Burstable `
    --admin-user $DB_ADMIN_USER `
    --admin-password $DB_ADMIN_PASSWORD `
    --sku-name $DB_SKU `
    --storage-size $DB_STORAGE_SIZE `
    --version 14 `
    --backup-retention 30 `
    --vnet $VNET_NAME `
    --subnet $DB_SUBNET

az postgres flexible-server db create `
    --resource-group $RESOURCE_GROUP `
    --server-name "payment-db-ci" `
    --name "payment_db"

# ===========================================
# 13. AKS
# ===========================================

Log-Operation "Creating AKS Cluster..."

az aks create `
    --resource-group $RESOURCE_GROUP `
    --name $AKS_CLUSTER_NAME `
    --location $LOCATION `
    --node-count 1 `
    --node-vm-size Standard_D2s_v3 `
    --vm-set-type VirtualMachineScaleSets `
    --enable-managed-identity `
    --network-plugin azure `
    --network-policy azure `
    --vnet-subnet-id "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$AKS_SUBNET" `
    --service-cidr 10.1.0.0/16 `
    --dns-service-ip 10.1.0.10 `
    --enable-cluster-autoscaler `
    --min-count 1 `
    --max-count 2 `
    --enable-aad `
    --aad-tenant-id $TENANT_ID `
    --workspace-resource-id $LAW_ID `
    --enable-addons monitoring

# ===========================================
# 14. WAF POLICY
# ===========================================

Log-Operation "Creating WAF Policy..."

az network application-gateway waf-policy create `
    --name $WAF_POLICY_NAME `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --type OWASP `
    --version 3.2

# ===========================================
# 15. APPLICATION GATEWAY
# ===========================================

Log-Operation "Creating Application Gateway..."

az network application-gateway create `
    --name $APPGW_NAME `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --capacity 2 `
    --sku WAF_v2 `
    --http-settings-cookie-based-affinity Disabled `
    --frontend-port 80 `
    --http-settings-port 80 `
    --http-settings-protocol Http `
    --priority 100 `
    --public-ip-address $APPGW_PIP `
    --vnet-name $VNET_NAME `
    --subnet $APPGW_SUBNET `
    --waf-policy $WAF_POLICY_NAME

# ===========================================
# 16. DNS
# ===========================================

Log-Operation "Creating DNS Zone..."

az network dns zone create `
    --resource-group $RESOURCE_GROUP `
    --name $DNS_ZONE

$APPGW_IP = az network public-ip show `
    --resource-group $RESOURCE_GROUP `
    --name $APPGW_PIP `
    --query ipAddress -o tsv

az network dns record-set a create `
    --resource-group $RESOURCE_GROUP `
    --zone-name $DNS_ZONE `
    --name "api" `
    --ttl 300

az network dns record-set a add-record `
    --resource-group $RESOURCE_GROUP `
    --zone-name $DNS_ZONE `
    --record-set-name "api" `
    --ipv4-address $APPGW_IP

# ===========================================
# 17. OUTPUTS
# ===========================================

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Infrastructure Deployment Complete!" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

$ACR_SERVER = az acr show `
    --resource-group $RESOURCE_GROUP `
    --name $ACR_NAME `
    --query loginServer -o tsv

$USER_DB_HOST = az postgres flexible-server show `
    --resource-group $RESOURCE_GROUP `
    --name "user-db-ci" `
    --query fullyQualifiedDomainName -o tsv

Write-Host "- Resource Group: $RESOURCE_GROUP"
Write-Host "- AKS Cluster: $AKS_CLUSTER_NAME"
Write-Host "- ACR: $ACR_SERVER"
Write-Host "- App Gateway IP: $APPGW_IP"
Write-Host "- User DB Host: $USER_DB_HOST"
Write-Host "- DNS: api.$DNS_ZONE"

Write-Host ""
Write-Host "Get AKS Credentials:" -ForegroundColor Yellow

Write-Host "az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --admin --overwrite-existing"

Write-Host ""
Write-Host "Verify Cluster:" -ForegroundColor Yellow

Write-Host "kubectl get nodes"

Write-Host ""
Write-Host "Deployment completed successfully!" -ForegroundColor Green