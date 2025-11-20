terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"               
    storage_account_name = "tfstate1763421769"        
    container_name       = "tfstate"                 
    key                  = "phase2.terraform.tfstate"  
    subscription_id      = "91877cd2-a4c2-49cc-b2e2-f5bfe05a0587"
  }
}

provider "azurerm" {
  subscription_id = "91877cd2-a4c2-49cc-b2e2-f5bfe05a0587"
  tenant_id       = "5775cf82-35e6-4f8c-b604-fcb7a5abce7f"
  features {}  
}

