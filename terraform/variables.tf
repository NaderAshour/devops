############################################
# Global / Common Variables
############################################

variable "env" {
  description = "Environment: dev or prod"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Resource group for all Azure resources"
  type        = string
  default     = "aks-rg"
}

############################################
# Networking Variables
############################################

variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
  default     = "aks-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Subnet name for AKS"
  type        = string
  default     = "aks-subnet"
}

variable "subnet_address_prefix" {
  description = "Subnet CIDR block for AKS"
  type        = string
  default     = "10.0.1.0/24"
}

############################################
# ACR Variables
############################################

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "tactfulacr"
}

variable "acr_sku" {
  description = "ACR SKU tier"
  type        = string
  default     = "Basic"
}

# we referenced to the principle directly in the acr.tf file but we keep it here for further updates 
#variable "aks_identity_principal_id" {
#  description = "Principal ID of AKS managed identity for ACR pull"
#  type        = string
#}

############################################
# AKS Variables
############################################

variable "aks_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for AKS"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "tags" {
  description = "Tags for Azure resources"
  type        = map(string)
  default     = {}
}

############################################
# KeyVault Variables
############################################

#variable "keyvault_name" {
#  description = "Name of the KeyVault"
#  type        = string
#  default     = "kv-${var.env}-${random_id.unique.hex}"
#}
#resource "random_id" "unique" {
 # byte_length = 2
#}

variable "secrets" {
  description = "Map of secrets (name → value) to store in KeyVault"
  type        = map(string)
}
