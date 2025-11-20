env                 = "dev"
location            = "westeurope"

resource_group_name = "tfstate-rg"

# Choose one consistent AKS name (I follow your pattern "dev-aks-cluster")
aks_name            = "dev-aks-cluster"
dns_prefix          = "devaks"

node_count          = 1
vm_size             = "Standard_B2s"

tags = {
  environment = "dev"
}

#keyvault_name = "dev-kv"

secrets = {
  POSTGRES-USER     = "postgres"
  POSTGRES-PASSWORD = "postgres"
  POSTGRES-DB       = "postgres"
}
