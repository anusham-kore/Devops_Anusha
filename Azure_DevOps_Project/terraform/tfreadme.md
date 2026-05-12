# 🚀 Azure DevOps Infrastructure with Terraform

This document provides a comprehensive explanation of the Terraform configuration that provisions a complete Azure infrastructure for a microservices-based application. The setup includes Kubernetes (AKS), networking, databases, security, and monitoring components.

## 📋 Table of Contents

- [Prerequisites](#-prerequisites)
- [Authentication](#-authentication)
- [Infrastructure Components](#-infrastructure-components)
- [Deployment Steps](#-deployment-steps)
- [Key Networking Concepts](#-key-networking-concepts)
- [Architecture Overview](#-architecture-overview)

## 🔧 Prerequisites

### Required Tools
- **Terraform** (~v1.0+)
- **Azure CLI** (for authentication)
- **kubectl** (for Kubernetes management)

### Azure Permissions
- Contributor role on subscription or resource group
- User Access Administrator role (for managed identities)

## 🔐 Authentication

### Method 1: Azure CLI Login
```bash
az login
```

### Method 2: Service Principal (Recommended for CI/CD)
Set these environment variables:
```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

## 🏗️ Infrastructure Components

### 1. 📦 Terraform Provider Configuration
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}
```

**Purpose**: Specifies the Azure Resource Manager provider for Terraform to communicate with Azure APIs.

**Version Constraint**: `~>3.0` means use version 3.x but avoid breaking changes in v4+.

### 2. 🔌 Azure Provider Initialization
```hcl
provider "azurerm" {
  features {}
}
```

**Purpose**: Initializes the Azure provider with default features enabled.

**Authentication**: Uses Azure CLI login or service principal credentials from environment variables.

### 3. 📊 Current Azure Account Details
```hcl
data "azurerm_client_config" "current" {}
```

**Purpose**: Retrieves current Azure context information including:
- Tenant ID
- Subscription ID
- Client ID (for service principals)

**Usage**: These values are referenced throughout the configuration for resource permissions and access control.

### 4. 📁 Resource Group
```hcl
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
```

**What is a Resource Group?**
Think of it as a folder in Azure that groups related resources together. All infrastructure components (AKS, VNet, databases, etc.) are organized within this resource group for easier management and billing.

### 5. 🌐 Virtual Network (VNet)
```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
```

**Azure VNet = AWS VPC**
Creates a private network environment where all Azure resources can communicate securely. The `10.1.0.0/16` CIDR block provides over 65,000 IP addresses for the entire infrastructure.

### 6. 🏠 Subnets

The configuration creates three specialized subnets:

#### 🔒 AKS Subnet (Private)
```hcl
resource "azurerm_subnet" "aks" {
  name                 = "${var.prefix}-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}
```
- **Purpose**: Hosts Kubernetes nodes and pods
- **Security**: Private subnet with no direct internet access
- **Traffic**: All outbound traffic routes through NAT Gateway

#### 🌍 Application Gateway Subnet (Public)
```hcl
resource "azurerm_subnet" "appgw" {
  name                 = "${var.prefix}-appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}
```
- **Purpose**: Dedicated subnet for Azure Application Gateway
- **Security**: Public subnet for internet-facing load balancer
- **Requirement**: Azure requires separate subnet for Application Gateway

#### 🗄️ Database Subnet (Private)
```hcl
resource "azurerm_subnet" "db" {
  name                 = "${var.prefix}-db-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.3.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}
```
- **Purpose**: Hosts PostgreSQL databases
- **Security**: Private subnet with service endpoints
- **Endpoints**: `Microsoft.Sql` enables secure database communication

### 7. 🌉 NAT Gateway
```hcl
resource "azurerm_nat_gateway" "nat" {
  name                    = "${var.prefix}-nat"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}
```

**Why NAT Gateway?**
Private subnets cannot directly access the internet. NAT Gateway provides secure outbound connectivity for:
- 📦 Downloading packages and updates
- 🐳 Pulling container images from Azure Container Registry
- 🔗 Accessing external APIs and services

### 8. 📡 Public IP for NAT Gateway
```hcl
resource "azurerm_public_ip" "nat_pip" {
  name                = "${var.prefix}-nat-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
```

**Purpose**: Provides a static public IP address for outbound traffic from private subnets through the NAT Gateway.

### 9. 🔗 Subnet NAT Gateway Associations
```hcl
resource "azurerm_subnet_nat_gateway_association" "aks_nat" {
  subnet_id      = azurerm_subnet.aks.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "db_nat" {
  subnet_id      = azurerm_subnet.db.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}
```

**Critical Concept**: In Azure, NAT Gateway is directly associated with subnets rather than through route tables. This enables all outbound traffic from AKS nodes and databases to flow securely through the NAT Gateway.

### 10. 🛡️ Network Security Groups (NSGs)
```hcl
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.prefix}-aks-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowAppGWInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.1.2.0/24"  # App Gateway subnet
    destination_address_prefix = "*"
  }
}
```

**Azure NSG = AWS Security Group**
Controls inbound and outbound traffic at the subnet level:
- **AKS NSG**: Allows traffic from Application Gateway to AKS services
- **App Gateway NSG**: Permits HTTP (80) and HTTPS (443) from internet

### 11. 🔗 NSG-Subnet Associations
```hcl
resource "azurerm_subnet_network_security_group_association" "aks_nsg_assoc" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}
```

**Purpose**: Attaches firewall rules to subnets. Without this association, NSG rules exist but don't apply to network traffic.

### 12. 🐳 Azure Container Registry (ACR)
```hcl
resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}
```

**Azure ACR = AWS ECR**
Secure private registry for Docker images:
- Stores microservice container images
- AKS pulls images securely without internet exposure
- Integrated authentication with AKS managed identity

### 13. ⚓ AKS (Azure Kubernetes Service) Cluster
```hcl
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_DS3_v2"
    zones      = [1, 2, 3]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
  }

  azure_policy_enabled = true
}
```

**Key AKS Features**:

#### Node Pool Configuration
- **node_count**: 3 worker nodes for high availability
- **vm_size**: `Standard_DS3_v2` (4 vCPUs, 14GB RAM)
- **zones**: Distributed across 3 availability zones

#### Identity & Security
- **SystemAssigned Identity**: Managed identity for secure Azure resource access
- **Azure Policy**: Governance and security compliance
- **OMS Agent**: Integration with Azure Monitor and Log Analytics

#### Networking
- **network_plugin**: "azure" (CNI) - each pod gets real VNet IP
- **load_balancer_sku**: "standard" for production-grade load balancing

### 14. 📊 Monitoring & Observability

#### Log Analytics Workspace
```hcl
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "${var.prefix}-logs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
```

Central logging and metrics collection for:
- Kubernetes cluster logs
- Application performance metrics
- Security monitoring and alerting

#### Application Insights
```hcl
resource "azurerm_application_insights" "app_insights" {
  name                = "${var.prefix}-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}
```

Application performance monitoring:
- Response times and failure rates
- Dependency tracking between microservices
- Real user monitoring and analytics

### 15. 💾 Storage Account
```hcl
resource "azurerm_storage_account" "storage" {
  name                     = "${var.prefix}storage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
```

**Capabilities**:
- File storage for backups and persistent volumes
- Blob storage for logs, assets, and Terraform state
- Geo-redundant storage (GRS) for disaster recovery

### 16. 🌐 Application Gateway
```hcl
resource "azurerm_application_gateway" "appgw" {
  name                = "${var.prefix}-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "public-ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.1"
  }
}
```

**Azure Application Gateway = Layer 7 Load Balancer**
Advanced features:
- **SSL Termination**: Handles HTTPS encryption/decryption
- **Path-based Routing**: Route traffic based on URL paths
- **Web Application Firewall (WAF)**: Protects against OWASP attacks
- **Load Balancing**: Distributes traffic across microservices

**Traffic Flow**:
```
Internet → Public IP → Application Gateway → AKS Services → Pods
```

### 17. 🌐 DNS Configuration
```hcl
resource "azurerm_dns_zone" "dns" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "api" {
  name                = "api"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.appgw_pip.id
}
```

Creates domain configuration:
- **DNS Zone**: `yourdomain.com`
- **A Record**: `api.yourdomain.com` → Application Gateway IP

### 18. 🗄️ PostgreSQL Databases
```hcl
resource "azurerm_postgresql_flexible_server" "user_db" {
  name                   = "${var.prefix}-user-db"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "13"
  administrator_login    = var.db_admin
  administrator_password = var.db_password
  sku_name               = "GP_Standard_D2s_v3"
  storage_mb             = 32768

  delegated_subnet_id = azurerm_subnet.db.id
  private_dns_zone_id = azurerm_private_dns_zone.db_dns.id
}
```

**Microservice Database Pattern**:
- **user-db**: User management and authentication
- **order-db**: Order processing and history
- **payment-db**: Payment processing and transactions

**Security Features**:
- **Private DNS Zone**: No public database exposure
- **Delegated Subnet**: Databases deployed in private subnet
- **VNet Integration**: Secure communication within private network

### 19. 🔐 Key Vault
```hcl
resource "azurerm_key_vault" "kv" {
  name                        = "${var.prefix}-kv"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}
```

**Azure Key Vault = AWS Secrets Manager**
Securely stores:
- Database passwords
- API keys and secrets
- SSL certificates
- Application configuration

**Production Features**:
- **Purge Protection**: Prevents accidental deletion
- **Soft Delete**: Recover deleted secrets within retention period

### 20. 👥 Role Assignments
```hcl
resource "azurerm_role_assignment" "aks_kv_secrets" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].principal_id
}
```

Grants AKS cluster permission to read secrets from Key Vault, enabling secure access to sensitive configuration without storing credentials in application code.

## 🚀 Deployment Steps

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Preview Changes**
   ```bash
   terraform plan -out=tfplan
   ```

3. **Apply Infrastructure**
   ```bash
   terraform apply tfplan
   ```

4. **Save Outputs**
   ```bash
   terraform output -json > outputs.json
   ```

5. **Configure kubectl**
   ```bash
   az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw aks_name)
   ```

## 🔧 Key Networking Concepts

- **🔓 Public Subnet**: Application Gateway subnet with direct internet access
- **🔒 Private Subnets**: AKS and database subnets without direct internet access
- **🌉 NAT Gateway**: Provides secure outbound internet access for private resources
- **🛡️ NSGs**: Firewall rules controlling traffic flow between subnets
- **🔗 Service Endpoints**: Secure communication to Azure services without public IPs
- **📡 Route Tables**: Custom routing rules for traffic flow (currently minimal but extensible)

## 🏛️ Architecture Overview

```
🌐 Internet
    ↓
🏠 Application Gateway + WAF (Public Subnet)
    ↓
⚓ AKS Cluster (Private Subnet)
    ↓
🐳 Microservices Pods
    ↓
🗄️ PostgreSQL Databases (Private Subnet)

🔗 Additional Connections:
AKS ↔ Azure Container Registry
AKS ↔ Key Vault
AKS ↔ Log Analytics
AKS ↔ Application Insights
```

**Security Boundaries**:
- 🔴 **Public Zone**: Application Gateway (internet-facing)
- 🟡 **DMZ**: Application Gateway subnet
- 🟢 **Private Zone**: AKS and databases (no direct internet access)

This infrastructure provides a production-ready, secure, and scalable foundation for microservices applications with comprehensive monitoring, security, and high availability features.
Managed Identity

Usually:

az login
3. Current Azure Account Details
data "azurerm_client_config" "current" {}

Fetches:

Tenant ID
Subscription ID
Client ID

Used later in:

Key Vault permissions
4. Resource Group
resource "azurerm_resource_group" "rg"
What is Resource Group?

Like a folder in Azure.

Everything inside:

AKS
VNet
DB
Storage
Gateway

gets grouped together.

5. Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet"
Azure VNet = AWS VPC

This creates private networking.

Example:

10.1.0.0/16

All Azure resources communicate inside this network.

### 6. Subnets

**Three subnets created**:

#### AKS Subnet (Private)
- Used by Kubernetes nodes and pods
- Contains the actual compute resources
- **Private subnet**: No direct internet access

#### Application Gateway Subnet (Public)
- Dedicated subnet for Azure Application Gateway
- Requires separate subnet per Azure requirements
- **Public subnet**: Internet-facing for load balancer

#### Database Subnet (Private)
- Used for PostgreSQL databases
- `service_endpoints = ["Microsoft.Sql"]` enables secure communication
- **Private subnet**: Isolated from internet for security

### 7. NAT Gateway
```hcl
resource "azurerm_nat_gateway" "nat"
```

**Purpose**: Enables outbound internet access for private subnet resources without public IPs.

**Why needed**: Private subnets can't directly access internet. NAT Gateway provides secure outbound connectivity for:
- Downloading packages/updates
- Pulling container images from ACR
- Accessing external APIs

### 8. Public IP for NAT Gateway
```hcl
resource "azurerm_public_ip" "nat_pip"
```

**Purpose**: Public IP address assigned to NAT Gateway for outbound traffic from private subnets.

### 9. Subnet NAT Gateway Associations
```hcl
resource "azurerm_subnet_nat_gateway_association" "aks_nat"
resource "azurerm_subnet_nat_gateway_association" "db_nat"
```

**Purpose**: Directly associates NAT Gateway with private subnets for outbound internet connectivity.

**Important**: In Azure, NAT Gateway is directly associated with subnets rather than through route table entries. This enables all outbound traffic from the subnet to flow through the NAT Gateway.

### 10. Route Table (Optional)
```hcl
resource "azurerm_route_table" "private_rt"
```

**Purpose**: Enables future custom routing rules if needed. Currently empty but ready for expansion.

7. Network Security Groups (NSG)
Azure NSG = AWS Security Group

Controls:

inbound traffic
outbound traffic
AKS NSG
AllowAppGWInbound

Allows traffic from:

Application Gateway → AKS
App Gateway NSG

Allows:

80 → HTTP
443 → HTTPS

So internet users can access app.

8. Associate NSG to Subnet
azurerm_subnet_network_security_group_association

This attaches firewall rules to subnet.

Without this:

NSG exists
but rules won’t apply
9. Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr"
Azure ACR = AWS ECR

Stores Docker images.

Example:

frontend:v1
backend:v2

AKS pulls images from ACR.

10. AKS Cluster
resource "azurerm_kubernetes_cluster" "aks"

This is Azure Kubernetes Service.

Equivalent:

Managed Kubernetes Cluster
Important AKS Concepts
default_node_pool
node_count = 3

Creates:

3 worker nodes
vm_size
Standard_DS3_v2

VM type for Kubernetes nodes.

Equivalent:

EC2 instance type
enable_auto_scaling
min_count = 3
max_count = 10

Cluster auto-scales based on load.

zones = [1,2,3]

Deploys nodes across availability zones.

Improves:

HA
fault tolerance
Identity
identity {
  type = "SystemAssigned"
}

Managed Identity for AKS.

Equivalent:

IAM Role for Service

AKS can securely access:

Key Vault
Storage
Other Azure services

without passwords.

Network Profile
network_plugin = "azure"

Azure CNI networking.

Each pod gets real VNet IP.

load_balancer_sku = "standard"

Production-grade load balancer.

OMS Agent
oms_agent

Connects AKS logs to:

Azure Monitor
Log Analytics
Azure Policy
azure_policy_enabled = true

Used for governance/security.

Example:

block privileged containers
enforce tags
security compliance
11. Monitoring
Log Analytics Workspace

Central place for:

logs
metrics
queries

Equivalent:

CloudWatch Logs + Elasticsearch
Application Insights

Application monitoring.

Tracks:

response time
failures
API performance
dependency calls

Very useful for microservices.

12. Storage Account
resource "azurerm_storage_account"

Azure Storage service.

Can store:

files
backups
logs
Terraform state
blobs
GRS
account_replication_type = "GRS"

Geo-redundant storage.

Data copied to another region.

13. Public IP
azurerm_public_ip

Public internet IP for:

Application Gateway
14. Application Gateway
Azure Application Gateway = Layer 7 Load Balancer

Can do:

SSL termination
path routing
WAF
load balancing
Flow
User
 ↓
Public IP
 ↓
Application Gateway
 ↓
AKS Service
 ↓
Pod
Backend Pool
backend_address_pool

Contains backend servers/pods.

Listener
http_listener

Listens on:

80 / 443
Routing Rule

Defines:

Incoming request → backend
WAF
WAF_v2

Web Application Firewall.

Protects from:

SQL injection
XSS
OWASP attacks
15. DNS
azurerm_dns_zone

Creates domain DNS zone.

Example:

mycompany.com
DNS A Record
api.mycompany.com

Points to:

Application Gateway public IP
16. PostgreSQL Flexible Server

Creates managed PostgreSQL databases.

Three DBs:

user-db
order-db
payment-db

Microservice architecture pattern.

Private DNS Zone

Enables:

Private DB access inside VNet

No public DB exposure.

Very important for security.

delegated_subnet_id

Database deployed inside private subnet.

17. Key Vault
Azure Key Vault = AWS Secrets Manager

Stores:

passwords
secrets
certificates
API keys
purge_protection_enabled

Prevents accidental deletion.

Production best practice.

18. Role Assignment
azurerm_role_assignment

Gives AKS permission to read secrets from Key Vault.

Equivalent:

AKS IAM Role → Secrets Manager Access
Overall Architecture
Internet
   ↓
Application Gateway + WAF
   ↓
AKS Cluster
   ↓
Microservices Pods
   ↓
PostgreSQL Databases

AKS also connects to:
- ACR
- Key Vault
- Monitoring
- Storage

## 🚀 Deployment Steps

1. `terraform init` - Initialize providers
2. `terraform plan` - Preview changes
3. `terraform apply` - Create infrastructure
4. `terraform output -json > outputs.json` - Save outputs

## 🔧 Key Networking Concepts

- **Public Subnet**: Application Gateway (internet-facing, direct internet access)
- **Private Subnets**: AKS nodes, databases (no direct internet access)
- **NAT Gateway**: Provides outbound internet access for private resources
- **Route Tables**: Direct traffic through NAT Gateway for outbound connectivity
- **NSGs**: Firewall rules controlling inbound/outbound traffic per subnet
- **Service Endpoints**: Secure communication to Azure services without public IPs