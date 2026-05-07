This Terraform code is creating a complete production-style Azure infrastructure using Terraform.

It includes:

Networking
AKS Kubernetes cluster
Application Gateway
PostgreSQL databases
Monitoring
Storage
DNS
Key Vault
Security

I’ll explain section by section in simple Azure terms.

1. Terraform Provider Section
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}
What this means

Terraform needs Azure plugin/provider to communicate with Azure APIs.

Equivalent meaning
Terraform → AzureRM Provider → Azure Cloud

~>3.0
means:

Use version 3.x
Avoid breaking changes from v4
2. Azure Provider Authentication
provider "azurerm" {
  features {}
}

This initializes Azure provider.

Terraform will authenticate using:

Azure CLI login
Service Principal
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

6. Subnets

Three subnets created:

aks_subnet
appgw_subnet
db_subnet
AKS Subnet

Used by:

Kubernetes nodes
Pods
App Gateway Subnet

Dedicated subnet for:

Azure Application Gateway

Azure requires App Gateway in separate subnet.

DB Subnet

Used for:

PostgreSQL databases
service_endpoints = ["Microsoft.Sql"]

Allows secure Azure SQL communication.

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