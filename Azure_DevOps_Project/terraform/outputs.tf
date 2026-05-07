output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_client_certificate" {
  value     = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "appgw_public_ip" {
  value = azurerm_public_ip.appgw_pip.ip_address
}

output "dns_zone_nameservers" {
  value = azurerm_dns_zone.dns.name_servers
}

output "api_endpoint_dns" {
  value = "api.${azurerm_dns_zone.dns.name}"
}

output "user_db_host" {
  value = azurerm_postgresql_flexible_server.user_db.fqdn
}

output "order_db_host" {
  value = azurerm_postgresql_flexible_server.order_db.fqdn
}

output "payment_db_host" {
  value = azurerm_postgresql_flexible_server.payment_db.fqdn
}

output "keyvault_uri" {
  value = azurerm_key_vault.vault.vault_uri
}

output "appinsights_instrumentation_key" {
  value     = azurerm_application_insights.appinsights.instrumentation_key
  sensitive = true
}

output "law_workspace_id" {
  value = azurerm_log_analytics_workspace.law.workspace_id
}