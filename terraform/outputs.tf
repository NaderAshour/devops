
########################################
# Networking Outputs
########################################

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

########################################
# Key Vault Outputs
########################################

output "keyvault_id" {
  value       = azurerm_key_vault.this.id
  description = "ID of the Key Vault"
}

output "keyvault_uri" {
  value       = azurerm_key_vault.this.vault_uri
  description = "URI of the Key Vault"
}

########################################
# AKS Outputs
########################################

output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks_cluster.name
  description = "Name of the AKS cluster"
}

output "aks_cluster_resource_group" {
  value       = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  description = "Resource group created automatically for AKS nodes"
}



output "aks_principal_id" {
  value       = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
  description = "Principal ID of the AKS managed identity (used for ACR role assignment)"
}
output "current_user_object_id" {
  value = data.azurerm_client_config.current.object_id
}


