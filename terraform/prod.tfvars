env                 = "prod"
location            = "westeurope"

resource_group_name = "tfstate-rg"

# Choose one consistent AKS name (I follow your pattern "prod-aks-cluster")
aks_name            = "prod-aks-cluster"
dns_prefix          = "prodaks"

node_count          = 1
vm_size             = "Standard_B2s"

tags = {
  environment = "prod"
}

#keyvault_name = "prod-kv"

secrets = {
  POSTGRES-USER     = "postgres"
  POSTGRES-PASSWORD = "postgres"
  POSTGRES-DB       = "postgres"
}
