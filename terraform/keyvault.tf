data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}

resource "random_id" "unique" {
  byte_length = 2
}

resource "azurerm_key_vault" "this" {
  name                = "kv-${var.env}-${random_id.unique.hex}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
    

    secret_permissions = [
      "Get",
      "List"
    ]
  }
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id  
    secret_permissions = ["Get", "List", "Set"]
  }

    depends_on = [
    azurerm_kubernetes_cluster.aks_cluster
  ]
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_secret" "secrets" {
  for_each = var.secrets

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id
}
