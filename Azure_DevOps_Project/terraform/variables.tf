variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "devops-prod-rg-centralindia"
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "centralindia"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

# Networking
variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
  default     = "devops-vnet"
}

variable "vnet_address_space" {
  description = "VNET address space"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_subnet_prefix" {
  description = "AKS subnet prefix"
  type        = string
  default     = "10.0.1.0/24"
}

variable "appgw_subnet_prefix" {
  description = "Application Gateway subnet prefix"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_subnet_prefix" {
  description = "Database subnet prefix"
  type        = string
  default     = "10.0.3.0/24"
}

# Container Registry
variable "acr_name" {
  description = "ACR name (must be unique globally)"
  type        = string
  default     = "devopsproductcrci"
}

# AKS
variable "aks_name" {
  description = "AKS cluster name"
  type        = string
  default     = "devops-prod-aks-ci"
}

# Application Gateway
variable "appgw_name" {
  description = "Application Gateway name"
  type        = string
  default     = "devops-appgw"
}

# DNS
variable "dns_zone_name" {
  description = "DNS zone name (domain name)"
  type        = string
  default     = "anusha-devops-demo.com"
}

# Logging & Monitoring
variable "law_name" {
  description = "Log Analytics Workspace name"
  type        = string
  default     = "devops-law"
}

variable "appinsights_name" {
  description = "Application Insights name"
  type        = string
  default     = "devops-appinsights"
}

# Storage
variable "storage_account_name" {
  description = "Storage account name (must be unique globally)"
  type        = string
  default     = "devopsprodstorage"
}

# Database
variable "db_admin_user" {
  description = "Database admin username"
  type        = string
  default     = "psqladmin"
}

variable "db_admin_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd123!Azure"
}

# Key Vault
variable "keyvault_name" {
  description = "Key Vault name (must be unique globally)"
  type        = string
  default     = "devops-prod-kv-ci-anusha-anusha01"
}